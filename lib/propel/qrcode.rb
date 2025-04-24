# frozen_string_literal: true

# frozen_string_literal: true
require 'rqrcode'
require 'fileutils'
require_relative 'utils/logger'
require_relative 'pdf/base_generator'
require_relative 'pdf/generators/qr_code'
require_relative 'qrcode/base_generator'
require_relative 'qrcode/variant_validator'

module Propel
  module Qrcode
    class ProductQrLabelGenerator < Propel::Pdf::Generators::Base
      def initialize(options = {})
        super
        @url = options[:url]
        @price = options[:price]
        @option = options[:option]
        @handle = options[:handle]
      end

      def generate_pdf
        # Create the QR code
        qr = RQRCode::QRCode.new(@url)
        qr_png = qr.as_png(size: 500, border_modules: 3)
        qr_data = qr_png.to_blob

        # Create a tempfile for the QR image
        temp_file = create_temp_file(suffix: '.png')
        temp_file.binmode
        temp_file.write(qr_data)
        temp_file.close

        # Create the PDF document
        document = create_document(
          page_size: [1.25 * 72, 1.25 * 72],
          margin: 5
        )

        # Calculate dimensions
        available_width = document.bounds.width
        available_height = document.bounds.height

        # Size the QR code to leave room for text (65% of height)
        qr_size = [available_width * 0.9, available_height * 0.65].min

        # Center the QR code horizontally and position it at the top
        x_position = (available_width - qr_size) / 2
        y_position = document.bounds.top

        # Add the QR code
        document.image temp_file.path,
                       at: [x_position, y_position],
                       width: qr_size

        # Add price and option text
        if @price && @option
          price_text = "$#{format('%.2f', @price)} - #{@option}"

          # Position for price text - below QR code with minimal spacing
          price_y = y_position - qr_size - 3

          document.font_size(12) do
            document.text_box price_text,
                              at: [0, price_y],
                              width: available_width,
                              height: 14,
                              align: :center
          end
        end

        # Add handle/SKU text below price with reduced spacing
        if @handle
          # Position for handle text - tighter spacing below price text
          handle_y = y_position - qr_size - 18

          document.font_size(10) do
            document.text_box @handle,
                              at: [0, handle_y],
                              width: available_width,
                              height: 12,
                              align: :center,
                              style: :italic
          end
        end

        # Return the rendered PDF
        document.render
      end

      def generate_filename
        "product_qr_#{@handle || Time.now.to_i}.pdf"
      end
    end

    class Generator
      def self.generate(options = {})
        generator = ProductQrLabelGenerator.new(options)
        result = generator.generate

        # Handle file output if path is specified
        if options[:output_path] && result.success?
          File.open(options[:output_path], 'wb') do |file|
            file.write(result.data)
          end

          # Log success or failure
          if File.exist?(options[:output_path])
            Propel.logger.info "File successfully created: #{options[:output_path]}"
            Propel.logger.info "File size: #{File.size(options[:output_path])} bytes"
          else
            Propel.logger.error "File was not created at #{options[:output_path]}"
          end
        end

        result
      end
    end
  end
end