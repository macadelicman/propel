# lib/prpl/pdf/sheet_generator.rb
module Prpl
  module Pdf
    class SheetGenerator < BaseGenerator
      require "prawn"

      # Generates a sheet of barcodes QR codes for a variant
      # Returns the PDF data as a binary string
      def self.generate_barcode_qr_sheet(variant, margins = {})
        column_gap   = sanitize_gap(margins[:column_gap] || 0.15748)  # 4mm
        row_gap      = sanitize_gap(margins[:row_gap] || 0.15748)     # 4mm
        top_margin   = sanitize_gap(margins[:top_margin] || 0.472441) # 12mm
        bottom_margin= sanitize_gap(margins[:bottom_margin] || 0.433071) # 11mm
        left_margin  = sanitize_gap(margins[:left_margin] || 0.393701) # 10mm
        right_margin = sanitize_gap(margins[:right_margin] || 0.393701) # 10mm

        margin_top    = top_margin * POINTS_PER_INCH
        margin_bottom = bottom_margin * POINTS_PER_INCH
        margin_left   = left_margin * POINTS_PER_INCH
        margin_right  = right_margin * POINTS_PER_INCH

        pdf = Prawn::Document.new(
          page_size: "LETTER",
          margin: [margin_top, margin_right, margin_bottom, margin_left]
        )

        columns = 7
        rows = 9
        usable_width  = pdf.bounds.width
        usable_height = pdf.bounds.height

        total_column_gaps = (columns - 1) * column_gap * POINTS_PER_INCH
        total_row_gaps    = (rows - 1) * row_gap * POINTS_PER_INCH
        label_width       = (usable_width - total_column_gaps) / columns
        label_height      = (usable_height - total_row_gaps) / rows

        labels = []
        if variant.barcode_qr_image.attached?
          Tempfile.create(['barcode_qr', '.png']) do |temp_file|
            temp_file.binmode
            temp_file.write(variant.barcode_qr_image.download)
            temp_file.rewind

            price = format_price(variant.variant_price)
            stock_quantity = variant.variant_inventory_quantity

            stock_quantity.times do
              labels << { qr_path: temp_file.path, price: price }
            end
          end
        else
          labels << { qr_path: nil, price: "N/A" }
        end

        labels.each_with_index do |label, index|
          column = index % columns
          row    = index / columns

          if row >= rows
            pdf.start_new_page
            row = 0
          end

          x_position = column * (label_width + column_gap * POINTS_PER_INCH)
          y_position = pdf.bounds.top - row * (label_height + row_gap * POINTS_PER_INCH)

          pdf.bounding_box([x_position, y_position], width: label_width, height: label_height) do
            if label[:qr_path] && File.exist?(label[:qr_path])
              pdf.image label[:qr_path], position: :center, fit: [label_width * 0.8, label_height * 0.6]
              pdf.move_down 10
              pdf.text label[:price], size: 10, align: :center
            else
              pdf.text "No Barcode QR", align: :center, size: 10
            end
          end
        end

        pdf.render
      end
    end
  end
end
