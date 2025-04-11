# lib/prpl/pdf/generators/roll_label.rb
module Prpl
  module PDF

    class RollLabel
      # You can use a constant defined in your gem's constants file;
      # if not, define it here.
      POINTS_PER_INCH = 72

      def initialize(variant)
        @variant = variant
        # Assume each variant belongs to a product; this is our collection target.
        @product = variant.thnk_product
      end

      # Returns the rendered PDF data as a string.
      def generate
        pdf = Prawn::Document.new(
          page_size: [POINTS_PER_INCH, POINTS_PER_INCH],
          margin: [2, 2, 2, 2] # 2 point margins
        )

        labels = collect_labels

        labels.each_with_index do |label, index|
          pdf.start_new_page unless index.zero?

          usable_width  = pdf.bounds.width
          usable_height = pdf.bounds.height
          qr_size       = [usable_width, usable_height * 0.8].min

          # Center the QR code on the page.
          x_position = (usable_width - qr_size) / 2
          y_position = usable_height - 2 - qr_size

          if File.exist?(label[:qr_path])
            pdf.image label[:qr_path],
                      at: [x_position, y_position + qr_size],
                      width: qr_size

            # Add the price text.
            pdf.font_size 8 do
              pdf.text_box label[:price],
                           at: [0, 12],
                           width: usable_width,
                           height: 10,
                           align: :center
            end
          end
        end

        pdf.render
      ensure
        cleanup_labels(labels)
      end

      private

        # Iterate through each variant of the product, download the QR image,
        # and create one label per unit in stock.
        def collect_labels
          labels = []
          @product.thnk_variants.each do |variant|
            next unless variant.qr_code_image.attached?

            # Download the QR code image to a temporary file.
            temp_file = Tempfile.new(['qr_code', '.png'])
            begin
              temp_file.binmode
              temp_file.write(variant.qr_code_image.download)
              temp_file.rewind

              price = ActionController::Base.helpers.number_to_currency(variant.variant_price, unit: '$')
              stock_quantity = variant.variant_inventory_quantity
              stock_quantity.times do
                labels << { qr_path: temp_file.path, price: price }
              end
            ensure
              temp_file.close
            end
          end
          labels
        end

        # Clean up all temporary files used for labels.
        def cleanup_labels(labels)
          labels&.each do |label|
            if label[:qr_path] && File.exist?(label[:qr_path])
              File.delete(label[:qr_path])
            end
          end
        end
    end
  end

end
