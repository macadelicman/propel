# lib/prpl/pdf/generators/qr_code.rb

require_relative 'base'
require 'prawn'
require 'rqrcode'
require 'chunky_png'

module Prpl
  module Pdf
    module Generators
      class QrCode < Base
        DEFAULT_QR_SIZE = [450, 450]
        DEFAULT_MARGIN = [40, 40, 40, 40]

        def initialize(options = {})
          super
          validate_qr_data!
          @qr_size = options[:qr_size] || DEFAULT_QR_SIZE
        end



        def generate_pdf
          Prpl.logger.info "Generating QR code PDF - #{qr_context.inspect}"

          document = create_document(
            page_size: options[:page_size] || :letter,
            margin: options[:margin] || DEFAULT_MARGIN
          )

          if qr_code_data
            add_qr_code(document)
            add_details(document) if show_details?
          else
            document.text "No QR Code Available",
                          align: :center,
                          size: 16
          end

          document.render
        end

        def generate_filename
          "qr_code_#{variant_identifier || Time.now.to_i}.pdf"
        end

        private

        def add_qr_code(document)
          temp_file_path = write_image_to_temp_file(qr_code_data)

          if File.exist?(temp_file_path)
            document.image temp_file_path,
                           fit: @qr_size,
                           position: options[:position] || :center
          end
        end

        def add_details(document)
          document.move_down 10

          if variant_sku
            document.text "SKU: #{variant_sku}",
                          size: 12,
                          align: :center
          end

          if variant_price
            document.text format_currency(variant_price),
                          size: 16,
                          align: :center
          end

          if options[:additional_text]
            document.move_down 5
            document.text options[:additional_text],
                          size: 10,
                          align: :center
          end
        end

        def show_details?
          options[:show_details] != false &&
            (variant_sku || variant_price || options[:additional_text])
        end

        def validate_qr_data!
          unless qr_code_data || options[:skip_validation]
            raise Prpl::Errors::Error, "QR code data must be provided"
          end
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

        def qr_context
          {
            variant_identifier: variant_identifier,
            variant_sku: variant_sku,
            has_qr: !qr_code_data.nil?,
            show_details: show_details?,
            qr_size: @qr_size,
            page_size: options[:page_size] || :letter
          }
        end
      end

      # Specialized QR Roll generator for continuous printing
      class QrCodeRoll < QrCode
        DEFAULT_ROLL_MARGIN = [2, 2, 2, 2]

        def initialize(options = {})
          super
          @stock_quantity = options[:stock_quantity] || 1
        end

        protected

        def generate_pdf
          Prpl.logger.info "Generating roll QR codes - #{roll_context.inspect}"

          document = create_roll_document
          generate_roll_labels(document)
          document.render
        end

        def generate_filename
          "qr_roll_#{variant_identifier || Time.now.to_i}.pdf"
        end

        private

        def create_roll_document
          Prawn::Document.new(
            page_size: [POINTS_PER_INCH, POINTS_PER_INCH],
            margin: DEFAULT_ROLL_MARGIN
          )
        end

        def generate_roll_labels(document)
          temp_file_path = write_image_to_temp_file(qr_code_data) if qr_code_data

          @stock_quantity.times do |index|
            document.start_new_page unless index.zero?

            if temp_file_path && File.exist?(temp_file_path)
              add_roll_label(document, temp_file_path)
            end
          end
        end

        def add_roll_label(document, image_path)
          dimensions = calculate_dimensions(document)

          document.image image_path,
                         at: [
                           dimensions[:x_position],
                           dimensions[:y_position] + dimensions[:qr_size]
                         ],
                         width: dimensions[:qr_size]

          if variant_price
            document.font_size 8 do
              document.text_box format_currency(variant_price),
                                at: [0, 12],
                                width: dimensions[:usable_width],
                                height: 10,
                                align: :center
            end
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

        def roll_context
          qr_context.merge(
            stock_quantity: @stock_quantity,
            roll_dimensions: [POINTS_PER_INCH, POINTS_PER_INCH]
          )
        end
      end
    end
  end
end