# lib/prpl/pdf/generators/single_label.rb
module Prpl
  module Pdf
    module Generators
      class SingleLabel < Base
        DEFAULT_IMAGE_SIZE = [450, 450]
        DEFAULT_MARGIN = [40, 40, 40, 40]

        def initialize(options = {})
          super
          validate_variant_data!
        end

        protected

          def generate_pdf
            Prpl.logger.info "Generating single label PDF", context: label_context

            document = create_document(margin: DEFAULT_MARGIN)

            if qr_code_data
              add_qr_code(document)
            else
              document.text "No QR Code Available", align: :center, size: 16
            end

            add_variant_details(document)

            document.render
          end

          def generate_filename
            "qr_code_#{variant_identifier}.pdf"
          end

        private

          def add_qr_code(document)
            temp_file_path = write_image_to_temp_file(qr_code_data)
            document.image temp_file_path,
                           fit: DEFAULT_IMAGE_SIZE,
                           position: :center
          end

          def add_variant_details(document)
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
          end

          def validate_variant_data!
            unless variant_identifier
              raise Prpl::Errors::Error, "Variant identifier must be provided"
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

          def format_currency(amount)
            return "$0.00" unless amount
            "$%.2f" % amount
          end

          def label_context
            {
              variant_identifier: variant_identifier,
              variant_sku: variant_sku,
              has_qr_code: !qr_code_data.nil?,
              page_size: :letter
            }
          end
      end
    end
  end
end