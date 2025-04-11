# lib/prpl/pdf/generators/roll_label.rb
module Prpl
  module Pdf
    module Generators
      class RollLabel < Base
        DEFAULT_MARGIN = [2, 2, 2, 2] # 2 point margins
        LABEL_HEIGHT_RATIO = 0.8      # QR code takes up 80% of usable height

        def initialize(options = {})
          super
          validate_required_data!
          @stock_quantity = options[:stock_quantity] || 1
        end

        protected

          def generate_pdf
            Prpl.logger.info "Generating roll labels PDF", context: roll_context

            document = create_roll_document
            generate_labels(document)
            document.render
          end

          def generate_filename
            "roll_labels_#{variant_identifier}.pdf"
          end

        private

          def create_roll_document
            Prawn::Document.new(
              page_size: [POINTS_PER_INCH, POINTS_PER_INCH],
              margin: DEFAULT_MARGIN
            )
          end

          def generate_labels(document)
            temp_file_path = write_image_to_temp_file(image_data) if image_data

            @stock_quantity.times do |index|
              document.start_new_page unless index.zero?

              if temp_file_path && File.exist?(temp_file_path)
                add_image_to_page(document, temp_file_path)
                add_price_to_page(document)
              end
            end
          end

          def add_image_to_page(document, image_path)
            dimensions = calculate_dimensions(document)

            document.image image_path,
                           at: [dimensions[:x_position], dimensions[:y_position] + dimensions[:qr_size]],
                           width: dimensions[:qr_size]
          end

          def add_price_to_page(document)
            dimensions = calculate_dimensions(document)

            document.font_size 8 do
              document.text_box price_text,
                                at: [0, 12],
                                width: dimensions[:usable_width],
                                height: 10,
                                align: :center
            end
          end

          def calculate_dimensions(document)
            usable_width = document.bounds.width
            usable_height = document.bounds.height
            qr_size = [usable_width, usable_height * LABEL_HEIGHT_RATIO].min

            {
              usable_width: usable_width,
              usable_height: usable_height,
              qr_size: qr_size,
              x_position: (usable_width - qr_size) / 2,
              y_position: usable_height - 2 - qr_size
            }
          end

          def validate_required_data!
            unless variant_identifier
              raise Prpl::Errors::Error, "Variant identifier must be provided"
            end

            unless variant_price || image_data
              raise Prpl::Errors::Error, "Either variant price or image data must be provided"
            end
          end

          def variant_identifier
            options[:variant_identifier]
          end

          def variant_price
            options[:variant_price]
          end

          def image_data
            options[:image_data]
          end

          def price_text
            return "" unless variant_price
            format_currency(variant_price)
          end

          def format_currency(amount)
            "$%.2f" % amount
          end

          def roll_context
            {
              variant_identifier: variant_identifier,
              stock_quantity: @stock_quantity,
              has_image: !image_data.nil?,
              has_price: !variant_price.nil?
            }
          end
      end
    end
  end
end