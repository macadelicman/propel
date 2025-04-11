require 'prawn'
require 'tempfile'
require_relative '../../utils/errors'
require_relative '../../utils/result'

module Prpl
  module Pdf
    module Generators
      class Base
        POINTS_PER_INCH = 72
        VALID_PAGE_SIZES = [:A4, :A3, :letter, :legal].freeze
        DEFAULT_MARGIN = 40

        DEFAULT_LAYOUT_OPTIONS = {
          column_gap: 0.15748,    # 4mm in inches
          row_gap: 0.15748,       # 4mm in inches
          top_margin: 0.472441,   # 12mm in inches
          bottom_margin: 0.433071,# 11mm in inches
          left_margin: 0.393701,  # 10mm in inches
          right_margin: 0.393701  # 10mm in inches
        }.freeze

        attr_reader :options, :layout_options

        def self.generate(**options)
          new(options).generate
        end

        def initialize(options = {})
          @options = options
          @layout_options = process_layout_options
          @temp_files = []
          validate_options!
        end

        def generate
          Prpl.logger.info "Generating PDF - #{generation_context.inspect}"

          pdf_data = generate_pdf

          Prpl::Result.success(
            data: pdf_data,
            metadata: {
              filename: generate_filename,
              content_type: 'application/pdf'
            }
          )
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "PDF generation failed: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Unexpected error in PDF generation: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Prpl::Result.error("PDF generation failed", status: :internal_server_error)
        ensure
          cleanup_temp_files
        end

        # Expose generate_filename as a public method so it can be called externally
        def generate_filename
          raise NotImplementedError, "Subclasses must implement #generate_filename"
        end

        protected

        def generate_pdf
          raise NotImplementedError, "Subclasses must implement #generate_pdf"
        end

        # Modified to convert symbol page sizes into dimension arrays.
        # Modify this method in lib/prpl/pdf/generators/base.rb
        def create_document(page_size: :letter, margin: DEFAULT_MARGIN)
          # Get the page size dimensions based on the symbol
          # Prawn has page sizes defined directly on Prawn::Document::SIZES
          ps = page_size.is_a?(Symbol) ? get_page_size(page_size) : page_size

          Prawn::Document.new(
            page_size: ps,
            margin: process_margins(margin)
          )
        end

        # Add this helper method to get page sizes
        def get_page_size(size_name)
          # This is a hash of standard page sizes in Prawn
          sizes = {
            A4: [595.28, 841.89],
            A3: [841.89, 1190.55],
            letter: [612.0, 792.0],
            legal: [612.0, 1008.0]
          }

          sizes[size_name.to_sym] || sizes[:letter]
        end

        def create_temp_file(prefix: 'prpl', suffix: '.png')
          temp_file = Tempfile.new([prefix, suffix])
          @temp_files << temp_file
          temp_file
        end

        def write_image_to_temp_file(image_data)
          temp_file = create_temp_file
          temp_file.binmode
          temp_file.write(image_data)
          temp_file.rewind
          temp_file.path
        end

        def points_from_inches(inches)
          inches * POINTS_PER_INCH
        end

        def sanitize_gap(value)
          Float(value)
        rescue ArgumentError, TypeError
          0.05 # default fallback from original controller
        end

        def process_margins(margin)
          case margin
          when Array
            margin.map { |m| points_from_inches(sanitize_gap(m)) }
          when Hash
            [
              points_from_inches(sanitize_gap(margin[:top] || DEFAULT_LAYOUT_OPTIONS[:top_margin])),
              points_from_inches(sanitize_gap(margin[:right] || DEFAULT_LAYOUT_OPTIONS[:right_margin])),
              points_from_inches(sanitize_gap(margin[:bottom] || DEFAULT_LAYOUT_OPTIONS[:bottom_margin])),
              points_from_inches(sanitize_gap(margin[:left] || DEFAULT_LAYOUT_OPTIONS[:left_margin]))
            ]
          else
            points_from_inches(sanitize_gap(margin))
          end
        end

        def process_layout_options
          layout_opts = DEFAULT_LAYOUT_OPTIONS.dup

          options.fetch(:layout, {}).each do |key, value|
            layout_opts[key] = sanitize_gap(value) if DEFAULT_LAYOUT_OPTIONS.key?(key)
          end

          layout_opts
        end

        private

        def validate_options!
          if options[:page_size] && !VALID_PAGE_SIZES.include?(options[:page_size].to_sym)
            raise Prpl::Errors::Error, "Invalid page size. Valid sizes are: #{VALID_PAGE_SIZES.join(', ')}"
          end
        end

        def cleanup_temp_files
          @temp_files.each do |temp_file|
            temp_file.close
            temp_file.unlink if temp_file.path && File.exist?(temp_file.path)
          rescue => e
            Prpl.logger.warn "Failed to cleanup temp file: #{e.message}"
          end
        end

        def generation_context
          {
            generator: self.class.name,
            page_size: options[:page_size] || :letter,
            layout_options: layout_options
          }
        end
      end
    end
  end
end