require 'parallel'
require 'etc'
require 'fileutils'

def extract_pages_with_pdftotext(pdf_file)
  # Create a directory based on the PDF file name (without extension)
  base_name = File.basename(pdf_file, File.extname(pdf_file))
  FileUtils.mkdir_p(base_name)

  # Use pdfinfo (part of poppler-utils) to determine the total number of pages.
  pdfinfo_output = `pdfinfo "#{pdf_file}"`
  unless pdfinfo_output =~ /Pages:\s+(\d+)/
    abort("Could not determine the number of pages in #{pdf_file}")
  end
  total_pages = $1.to_i

  # Determine the number of processes (using available processors)
  process_count = (Etc.respond_to?(:nprocessors) ? Etc.nprocessors : 4)
  process_count = [process_count, total_pages].min

  # Process each page concurrently using Parallel
  Parallel.each(1..total_pages, in_processes: process_count) do |page_num|
    # Build the output filename (one text file per page)
    output_file = File.join(base_name, "page_#{page_num}.txt")
    # -f sets the first page and -l the last page (so one page is processed)
    command = %(pdftotext -f #{page_num} -l #{page_num} "#{pdf_file}" "#{output_file}")
    # Execute the command
    system(command)
    puts "Saved page #{page_num} to #{output_file}"
  end
end

if __FILE__ == $0
  pdf_file = 'DSM-5.pdf'
  extract_pages_with_pdftotext(pdf_file)
end
