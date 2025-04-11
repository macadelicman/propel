# lib/prpl/services/search/qr.rb
module Prpl
  module Services
    module Search
      class Qr < Base
        DEFAULT_LIMIT = 1

        def perform
          return empty_result if query.blank?
          validate_scope!

          Prpl.logger.info "Performing QR code search", context: search_context

          results = find_by_qr

          if results.any?
            handle_successful_search(results.first)
          else
            handle_empty_search
          end
        rescue Prpl::Errors::ConfigurationError => e
          Prpl.logger.error "Configuration error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          log_error(e, search_context)
          Prpl::Result.error(
            "QR code search failed",
            status: :internal_server_error
          )
        end

        private

          def find_by_qr
            strategy = determine_search_strategy
            results = strategy.call
            Array(results).compact.first(DEFAULT_LIMIT)
          end

          def determine_search_strategy
            if scope.respond_to?(:find_by_qr_data)
              -> { [scope.find_by_qr_data(query)] }
            elsif options[:matcher]
              -> { [options[:matcher].call(query, scope)] }
            else
              -> { basic_search }
            end
          end

          def basic_search
            field = options[:match_field] || :qr_data

            if scope.respond_to?(:where)
              scope.where(field => query).limit(DEFAULT_LIMIT)
            else
              scope.select { |item| item.respond_to?(field) && item.public_send(field) == query }
            end
          end

          def handle_successful_search(result)
            Prpl.logger.info "Found matching result", context: result_context(result)

            Prpl::Result.success(
              data: result,
              metadata: build_metadata([result]).merge(
                redirect_url: build_redirect_url(result)
              )
            )
          end

          def handle_empty_search
            Prpl.logger.warn "No matches found", context: search_context

            Prpl::Result.error(
              'No matching product found',
              status: :not_found
            )
          end

          def build_redirect_url(result)
            if options[:url_builder]
              options[:url_builder].call(result)
            else
              default_redirect_url(result)
            end
          end

          def default_redirect_url(result)
            id = result.respond_to?(:id) ? result.id : result.to_s
            "/products/#{id}"
          end

          def search_context
            {
              query: query,
              search_type: :qr,
              matcher_type: options[:matcher] ? 'custom' : 'default',
              match_field: options[:match_field]
            }
          end

          def result_context(result)
            {
              result_id: result.respond_to?(:id) ? result.id : nil,
              result_type: result.class.name,
              processing_time: calculate_processing_time
            }.compact
          end
      end
    end
  end
end