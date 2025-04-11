# lib/prpl/pdf/generators/sheet.rb
module Prpl
  module Pdf
    module Generators
      class Sheet < Base
        GRID_DEFAULTS = {
          columns: 7,
          rows: 9
        }.freeze

        def initialize(options = {})
          super
          @grid_options = GRID_DEFAULTS.merge(options.fetch(:grid, {}))
          @labels = process_labels
          validate_sheet_data!
        end

        protected

          def generate_pdf
            Prpl.logger.info "Generating sheet PDF", context: sheet_context

            document = create_sheet_document
            generate_sheet_content(document)
            document.render
          end

          def generate_filename
            prefix = options[:filename_prefix] || "sheet"
            suffix = options[:filename_suffix] || Time.now.to_i
            "#{prefix}_#{suffix}.pdf"
          end

        private

          def create_sheet_document
            Prawn::Document.new(
              page_size: options[:page_size] || "LETTER",
              margin: calculate_document_margins
            )
          end

          def generate_sheet_content(document)
            dimensions = calculate_grid_dimensions(document)
            current_page = 0

            @labels.each_with_index do |label, index|
              handle_page_break(document, index, dimensions)
              add_label_to_grid(document, label, index, dimensions)
            end
          end

          def handle_page_break(document, index, dimensions)
            row = (index / dimensions[:columns]).floor

            if row >= dimensions[:rows]
              document.start_new_page
              return true
            end

            false
          end

          def add_label_to_grid(document, label, index, dimensions)
            row = (index / dimensions[:columns]) % dimensions[:rows]
            column = index % dimensions[:columns]

            x_position = column * (dimensions[:label_width] + dimensions[:column_gap])
            y_position = document.bounds.top - row * (dimensions[:label_height] + dimensions[:row_gap])

            document.bounding_box([x_position, y_position],
                                  width: dimensions[:label_width],
                                  height: dimensions[:label_height]) do

              if label[:image_data]
                add_image_to_cell(document, label, dimensions)
              else
                document.text "No Image Available",
                              align: :center,
                              size: 10,
                              valign: :center
              end

              if label[:price]
                document.move_down 10
                document.text format_currency(label[:price]),
                              size: 10,
                              align: :center
              end
            end
          end

          def add_image_to_cell(document, label, dimensions)
            temp_file_path = write_image_to_temp_file(label[:image_data])

            if File.exist?(temp_file_path)
              document.image temp_file_path,
                             position: :center,
                             fit: [
                                         dimensions[:label_width] * 0.8,
                                         dimensions[:label_height] * 0.6
                                       ]
            end
          end

          def calculate_grid_dimensions(document)
            usable_width = document.bounds.width
            usable_height = document.bounds.height

            column_gap = points_from_inches(layout_options[:column_gap])
            row_gap = points_from_inches(layout_options[:row_gap])

            total_column_gaps = (@grid_options[:columns] - 1) * column_gap
            total_row_gaps = (@grid_options[:rows] - 1) * row_gap

            label_width = (usable_width - total_column_gaps) / @grid_options[:columns]
            label_height = (usable_height - total_row_gaps) / @grid_options[:rows]

            {
              columns: @grid_options[:columns],
              rows: @grid_options[:rows],
              label_width: label_width,
              label_height: label_height,
              column_gap: column_gap,
              row_gap: row_gap
            }
          end

          def calculate_document_margins
            [
              points_from_inches(layout_options[:top_margin]),
              points_from_inches(layout_options[:right_margin]),
              points_from_inches(layout_options[:bottom_margin]),
              points_from_inches(layout_options[:left_margin])
            ]
          end

          def process_labels
            return [] unless options[:labels]

            options[:labels].map do |label|
              {
                image_data: label[:image_data],
                price: label[:price],
                identifier: label[:identifier]
              }
            end
          end

          def validate_sheet_data!
            raise Prpl::Errors::Error, "No labels provided" if @labels.empty?
          end

          def sheet_context
            {
              total_labels: @labels.size,
              grid: @grid_options,
              page_size: options[:page_size] || "LETTER",
              margins: layout_options
            }
          end
      end
    end
  end
end