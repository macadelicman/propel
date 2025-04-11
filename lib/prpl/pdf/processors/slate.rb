# lib/pdf_extractor/extractor.rb

require 'pdf/reader'
require 'fileutils'
require 'stringio'
require 'parallel'
require 'etc'

module Prpl
  module PDF
    module Processors
      class Extractor
        attr_reader :pdf_file, :output_dir, :process_count

        # Initializes the extractor.
        #
        # @param pdf_file [String] the path to the input PDF.
        # @param output_dir [String, nil] the directory to store the extracted pages.
        #   Defaults to a directory named after the PDF (without its extension).
        # @param process_count [Integer, nil] the number of processes to use.
        #   Defaults to the number of available processors.
        def initialize(pdf_file:, output_dir: nil, process_count: nil)
          @pdf_file = pdf_file
          @output_dir = output_dir || File.basename(pdf_file, File.extname(pdf_file))
          FileUtils.mkdir_p(@output_dir)
          @process_count = process_count || (Etc.respond_to?(:nprocessors) ? Etc.nprocessors : 4)
          @pdf_data = File.binread(pdf_file)
        end

        # Extracts text from each page of the PDF and saves it into separate text files.
        def extract_pages
          # Determine the total number of pages using an initial reader.
          initial_reader = PDF::Reader.new(StringIO.new(@pdf_data))
          total_pages = initial_reader.page_count

          # Use as many processes as available, but no more than the number of pages.
          processes = [@process_count, total_pages].min

          Parallel.each(1..total_pages, in_processes: processes) do |page_num|
            # Each process creates its own reader instance.
            reader = PDF::Reader.new(StringIO.new(@pdf_data))
            page = reader.page(page_num)
            text = page.text

            # Save the extracted text into a file named "page_<number>.txt"
            output_filename = File.join(@output_dir, "page_#{page_num}.txt")
            File.open(output_filename, 'w:utf-8') { |f| f.write(text) }
            puts "Saved page #{page_num} to #{output_filename}"
          end
        end
      end
    end
  end
end
