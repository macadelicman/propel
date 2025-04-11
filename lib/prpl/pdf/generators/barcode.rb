# lib/prpl/pdf/generators/barcode.rb
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/prawn_outputter'

module Prpl
  module Pdf
    module Generators
      class Barcode < Base
        BARCODE_OPTIONS = {
          height: 50,
          xdim: 2,
          margin: 5
        }.freeze

        BARCODE_DEFAULTS = {
          width: 200,
          text_size: {
            sku: 12,
            price: 16
          }
        }.freeze

        def initialize(options = {})
          super
          validate_barcode_data!
          @barcode_options = BARCODE_OPTIONS.merge(options.fetch(:barcode_options, {}))
        end

        protected

        def generate_pdf
          Prpl.logger.info "Generating barcode PDF", context: barcode_context

          document = create_document(
            page_size: options[:page_size] || :letter,
            margin: calculate_margins
          )

          if barcode_content.present?
            add_barcode(document)
          else
            document.text "No Barcode Available",
                          align: :center,
                          valign: :center
          end

          add_details(document)
          document.render
        end

        def generate_filename
          "barcode_#{variant_identifier}.pdf"
        end

        private

        def add_barcode(document)
          barcode = Barby::Code128B.new(barcode_content)

          temp_file_path = generate_barcode_image(barcode)

          if temp_file_path && File.exist?(temp_file_path)
            document.image temp_file_path,
                           at: [document.bounds.left, document.cursor],
                           width: BARCODE_DEFAULTS[:width]
          end
        end

        def generate_barcode_image(barcode)
          temp_file = create_temp_file(prefix: 'barcode', suffix: '.png')
          temp_file.binmode

          barcode_image = barcode.to_png(
            height: @barcode_options[:height],
            xdim: @barcode_options[:xdim],
            margin: @barcode_options[:margin]
          )

          temp_file.write(barcode_image)
          temp_file.rewind
          temp_file.path
        end

        def add_details(document)
          document.move_down 10

          if variant_sku
            document.text "SKU: #{variant_sku}",
                          align: :center,
                          size: BARCODE_DEFAULTS[:text_size][:sku]
          end

          if variant_price
            document.text format_currency(variant_price),
                          align: :center,
                          size: BARCODE_DEFAULTS[:text_size][:price]
          end
        end

        def calculate_margins
          if options[:margins]
            process_margins(options[:margins])
          else
            process_margins(layout_options)
          end
        end

        def validate_barcode_data!
          unless variant_identifier && (barcode_content || qr_code_data)
            raise Prpl::Errors::Error, "Variant identifier and either barcode content or QR code data must be provided"
          end
        end

        def barcode_content
          options[:barcode_content]
        end

        def variant_identifier
          options[:variant_identifier]
        end

        def variant_sku
          options[:variant_sku]
        end

        def variant_price
          options[:variant_price]
        end

        def qr_code_data
          options[:qr_code_data]
        end

        def barcode_context
          {
            variant_identifier: variant_identifier,
            variant_sku: variant_sku,
            has_barcode: !barcode_content.nil?,
            has_qr: !qr_code_data.nil?,
            barcode_options: @barcode_options
          }
        end
      end

      # Specialized version for Barcode QR combinations
      class BarcodeQr < Barcode
        def initialize(options = {})
          super
          validate_qr_data!
        end

        protected

        def generate_pdf
          Prpl.logger.info "Generating barcode QR PDF", context: barcode_context

          document = create_document(
            page_size: [POINTS_PER_INCH, POINTS_PER_INCH],
            margin: [2, 2, 2, 2]  # 2 point margins for roll printing
          )

          if qr_code_data
            add_qr_code(document)
            add_price_to_page(document)
          else
            document.text "No QR Code Available",
                          align: :center,
                          size: 16
          end

          document.render
        end

        def generate_filename
          "barcode_qr_#{variant_identifier}.pdf"
        end

        private

        def add_qr_code(document)
          dimensions = calculate_dimensions(document)
          temp_file_path = write_image_to_temp_file(qr_code_data)

          if File.exist?(temp_file_path)
            document.image temp_file_path,
                           at: [
                                 dimensions[:x_position],
                                 dimensions[:y_position] + dimensions[:qr_size]
                               ],
                           width: dimensions[:qr_size]
          end
        end

        def add_price_to_page(document)
          dimensions = calculate_dimensions(document)

          document.font_size 8 do
            document.text_box format_currency(variant_price),
                              at: [0, 12],
                              width: dimensions[:usable_width],
                              height: 10,
                              align: :center
          end
        end

        def calculate_dimensions(document)
          usable_width = document.bounds.width
          usable_height = document.bounds.height
          qr_size = [usable_width, usable_height * 0.8].min

          {
            usable_width: usable_width,
            usable_height: usable_height,
            qr_size: qr_size,
            x_position: (usable_width - qr_size) / 2,
            y_position: usable_height - 2 - qr_size
          }
        end

        def validate_qr_data!
          unless qr_code_data
            raise Prpl::Errors::Error, "QR code data must be provided for BarcodeQr generation"
          end
        end
      end
    end
  end
end