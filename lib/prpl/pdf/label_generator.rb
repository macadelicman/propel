# lib/prpl/pdf/label_generator.rb
module Prpl
  module Pdf
    class LabelGenerator < BaseGenerator
      require "prawn"

      # Generates a single label PDF for a variant
      # Returns the PDF data as a binary string
      def self.generate_single_label(variant)
        Prawn::Document.new(page_size: :letter, margin: [40, 40, 40, 40]) do |pdf|
          if variant.qr_code_image.attached?
            # Assuming ActiveStorage or similar; adjust as needed
            Tempfile.create(['qr_code', '.png']) do |temp_file|
              temp_file.binmode
              temp_file.write(variant.qr_code_image.download)
              temp_file.rewind
              pdf.image temp_file.path, fit: [450, 450], position: :center
            end
          else
            pdf.text "No QR Code Available", align: :center, size: 16
          end

          pdf.move_down 10
          pdf.text "SKU: #{variant.variant_sku}", size: 12, align: :center
          pdf.text format_price(variant.variant_price), size: 16, align: :center
        end.render
      end
    end
  end
end
