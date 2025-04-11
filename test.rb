# First, load your logger
require_relative 'lib/prpl/utils/logger'

# Then load the required libraries and PDF generator
require_relative 'lib/prpl/pdf/generators/qr_code'
require 'rqrcode'
require 'fileutils'

# Create the Result and Error classes if not defined
unless defined?(Prpl::Result)
  module Prpl
    class Result
      attr_reader :data, :metadata, :error, :status

      def self.success(data:, metadata: {})
        new(success: true, data: data, metadata: metadata)
      end

      def self.error(message, status: nil)
        new(success: false, error: message, status: status)
      end

      def initialize(success:, data: nil, metadata: {}, error: nil, status: nil)
        @success = success
        @data = data
        @metadata = metadata
        @error = error
        @status = status
      end

      def success?
        @success
      end
    end

    module Errors
      class Error < StandardError; end
    end
  end
end

# Product QR Label Generator with Text
class ProductQrLabelGenerator < Prpl::Pdf::Generators::Base
  def initialize(options = {})
    super
    @url = options[:url]
    @price = options[:price]
    @option = options[:option]
    @handle = options[:handle]
  end

  def generate_pdf
    # Create the QR code
    qr = RQRCode::QRCode.new(@url || "https://rodaqr.fly.dev")
    qr_png = qr.as_png(size: 500, border_modules: 3)
    qr_data = qr_png.to_blob

    # Create a tempfile for the QR image
    temp_file = create_temp_file(suffix: '.png')
    temp_file.binmode
    temp_file.write(qr_data)
    temp_file.close

    # Create the PDF document
    document = Prawn::Document.new(
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
      price_y = y_position - qr_size - 3 # Reduced from 5 to 3

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
      handle_y = y_position - qr_size - 18 # Reduced from 25 to 18

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

# Generate the PDF
begin
  puts "Starting QR code generation with tighter text spacing..."

  result = ProductQrLabelGenerator.generate(
    url: "https://example.com/products/bubbly-vase",
    price: 55.00,
    option: "Navy Blue",
    handle: "bubbly-vase"
  )

  if result.success?
    # Get absolute file path
    output_dir = Dir.pwd
    output_file = File.join(output_dir, "product_qr_label.pdf")

    puts "Saving PDF to: #{output_file}"

    # Write the file
    File.open(output_file, 'wb') do |file|
      file.write(result.data)
    end

    # Verify file was created
    if File.exist?(output_file)
      puts "File successfully created: #{output_file}"
      puts "File size: #{File.size(output_file)} bytes"
    else
      puts "ERROR: File was not created at #{output_file}"
    end
  else
    puts "Error: #{result.error}"
  end
rescue => e
  puts "Exception occurred: #{e.message}"
  puts e.backtrace.join("\n")
end