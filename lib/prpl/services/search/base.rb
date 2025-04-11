module Prpl
  module Services
    module Search
      class Base
        attr_reader :query, :options, :scope

        def self.perform(query:, **options)
          new(query, options).perform
        end

        def initialize(query, **options)
          @query = query&.strip
          @options = options
          @scope = options[:scope]
          @start_time = Time.now
        end

        protected

          def validate_scope!
            unless scope
              Prpl.logger.error "No scope provided for search"
              raise Prpl::Errors::ConfigurationError, "Search scope must be provided"
            end
          end

          def build_metadata(results)
            {
              search_type: options[:search_type],
              processing_time: calculate_processing_time,
              total_results: get_result_count(results),
              query: query
            }.compact
          end

          def calculate_processing_time
            ((Time.now - @start_time) * 1000).round(2)
          end

          def get_result_count(results)
            return 0 if results.nil?
            return results.count if results.respond_to?(:count)
            return results.length if results.respond_to?(:length)
            results.to_a.length
          rescue => e
            Prpl.logger.warn "Could not determine result count: #{e.message}"
            0
          end

          def empty_result
            Prpl::Result.success(
              data: [],
              metadata: build_metadata([])
            )
          end

          def log_error(error, context = {})
            Prpl.logger.error "Search error: #{error.message}"
            Prpl.logger.error "Context: #{context.inspect}"
            Prpl.logger.error error.backtrace.join("\n") if error.backtrace
          end
      end
    end
  end
end