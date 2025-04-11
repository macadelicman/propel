module Prpl
  module Qrcode

    class BaseGenerator
      include Constants

      attr_reader :output_dir

      def initialize(output_dir = Rails.root.join('qrpdfs'))
        @output_dir = output_dir
        FileUtils.mkdir_p(@output_dir)
      end

      def generate_all
        puts "Starting QR code generation..."

        ThnkVariant.find_each do |variant|
          generate_for_variant(variant)
        end

        puts "Done generating QR labels in qrpdfs directory"
      end

      private

        def generate_for_variant(variant)
          return unless variant.thnk_product&.handle

          validator = VariantValidator.new(variant)
          unless validator.valid?
            puts "Skipping invalid variant #{variant.id} - Invalid color/size combination"
            return
          end

          puts "\nProcessing variant #{variant.id}"
          puts "SKU: #{variant.variant_sku}"

          qr_data = QrCodeData.new(variant, validator)
          qr_image = QrCodeImage.new(qr_data.product_url)
          pdf_generator = QrCodePdfGenerator.new(qr_image, qr_data)

          pdf_generator.generate_pdf(output_path(variant))
        rescue => e
          puts "Error processing variant #{variant.id}: #{e.message}"
        end

        def output_path(variant)
          File.join(output_dir, "qr_label_#{variant.variant_sku}.pdf")
        end
    end

    class QrCodeData
      attr_reader :variant, :inventory, :validator

      def initialize(variant, validator)
        @variant = variant
        @validator = validator
        @inventory = ThnkInventory.find_by(sku: variant.variant_sku)
        log_inventory_details
      end

      def product_url
        base_url = "https://thnk.com/products/#{variant.thnk_product.handle}"
        if variant.shopify_variant_id.present?
          cleaned_id = variant.shopify_variant_id.split('/').last
          "#{base_url}?variant=#{cleaned_id}"
        else
          base_url
        end
      end

      def price_text
        "$#{format('%.2f', variant.variant_price)}"
      end

      def display_text
        code = validator.variant_code
        code ? "#{price_text} - #{code}" : price_text
      end

      private

        def log_inventory_details
          puts "Found inventory? #{inventory ? 'Yes' : 'No'}"
          if inventory
            puts "Color: #{inventory.option1_value}"
            puts "Size: #{inventory.option2_value}"
            puts "Variant Code: #{validator.variant_code}"
          end
        end
    end

    class QrCodeImage
      attr_reader :url

      def initialize(url)
        @url = url
      end

      def generate
        qr = generate_qr_code
        generate_png(qr)
      end

      private

        def generate_qr_code
          version = 10
          loop do
            begin
              return RQRCode::QRCode.new(url, size: version, level: :q)
            rescue StandardError => e
              if e.message.include?('code length overflow') && version < 40
                version += 1
              else
                raise
              end
            end
          end
        end

        def generate_png(qr)
          qr.as_png(
            bit_depth: 1,
            border_modules: 4,
            color_mode: ChunkyPNG::COLOR_GRAYSCALE,
            color: 'black',
            fill: 'white',
            module_px_size: 6
          )
        end
    end

    class QrCodePdfGenerator
      IMAGE_WIDTH = 300
      FONT_SIZE = 24

      def initialize(qr_image, qr_data)
        @qr_image = qr_image
        @qr_data = qr_data
      end

      def generate_pdf(output_path)
        png_data = @qr_image.generate
        temp_file = create_temp_file(png_data)

        begin
          generate_pdf_with_image(temp_file, output_path)
        ensure
          cleanup_temp_file(temp_file)
        end
      end

      private

        def create_temp_file(png_data)
          temp_file = Tempfile.new(['qr', '.png'])
          temp_file.binmode
          temp_file.write(png_data.to_blob)
          temp_file.rewind
          temp_file
        end

        def generate_pdf_with_image(temp_file, output_path)
          Prawn::Document.new(page_size: "LETTER", margin: [40, 40, 40, 40]) do |pdf|
            add_centered_image(pdf, temp_file)
            add_text(pdf)
            pdf.render_file(output_path)
          end
        end

        def add_centered_image(pdf, temp_file)
          x = pdf.bounds.left + (pdf.bounds.width - IMAGE_WIDTH) / 2.0
          y = pdf.cursor
          pdf.image temp_file.path, fit: [IMAGE_WIDTH, IMAGE_WIDTH], at: [x, y]
          pdf.move_down IMAGE_WIDTH + 20
        end

        def add_text(pdf)
          pdf.text @qr_data.display_text,
                   size: FONT_SIZE,
                   align: :center,
                   style: :light
        end

        def cleanup_temp_file(temp_file)
          temp_file.close
          temp_file.unlink
        end
    end
  end
end