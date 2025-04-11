# lib/prpl/pdf/barcode_generator.rb
module Prpl
  module Pdf
    class BarcodeGenerator < BaseGenerator
      require "prawn"
      require "barby"
      require "barby/outputter/prawn_outputter"

      # Generates a barcode PDF for a variant
      # Returns the PDF data as a binary string
      def self.generate_barcode_pdf(variant)
        Prawn::Document.new(page_size: :letter, margin: [40, 40, 40, 40]) do |pdf|
          if variant.variant_barcode.present?
            barcode = Barby::Code128B.new(variant.variant_barcode)
            barcode_image = barcode.to_png(xdim: 2, height: 50)

            Tempfile.create(['barcode', '.png']) do |temp_file|
              temp_file.binmode
              temp_file.write(barcode_image)
              temp_file.rewind
              pdf.image temp_file.path, at: [pdf.bounds.left, pdf.cursor], width: 200
            end
          else
            pdf.text "No Barcode Available", align: :center, size: 16
          end

          pdf.move_down 10
          pdf.text "SKU: #{variant.variant_sku}", align: :center, size: 12
          pdf.text format_price(variant.variant_price), align: :center, size: 16
        end.render
      end
    end
  end
end
