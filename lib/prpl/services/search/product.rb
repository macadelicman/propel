# lib/prpl/services/search/product.rb
module Prpl
  module Services
    module Search
      class Product < Base
        def perform
          return empty_result if query.blank?
          validate_scope!

          Prpl.logger.info "Performing product search", context: search_context

          results = handle_db_operation

          Prpl.logger.info "Search completed", context: result_context(results)

          Prpl::Result.success(
            data: results,
            metadata: build_metadata(results)
          )
        rescue Prpl::Errors::ConfigurationError => e
          Prpl.logger.error "Configuration error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          log_error(e, search_context)
          Prpl::Result.error(
            "Search operation failed",
            status: :internal_server_error
          )
        end

        private

          def handle_db_operation
            if scope.respond_to?(:where)
              build_active_record_query
            else
              filter_enumerable
            end
          end

          def build_active_record_query
            scope.where(search_conditions, query: "%#{query}%")
          end

          def filter_enumerable
            scope.select do |item|
              searchable_attributes.any? do |attr|
                value = item.respond_to?(attr) ? item.public_send(attr) : nil
                value.to_s.downcase.include?(query.downcase)
              end
            end
          end

          def search_conditions
            searchable_attributes.map do |attr|
              "#{attr} ILIKE :query"
            end.join(' OR ')
          end

          def searchable_attributes
            options[:searchable_attributes] || [
              :title,
              :handle,
              :vendor,
              :product_category,
              :product_type,
              :variant_sku
            ]
          end

          def search_context
            {
              query: query,
              search_type: options[:search_type],
              searchable_attributes: searchable_attributes,
              scope_type: scope.class.name
            }
          end

          def result_context(results)
            {
              total_results: get_result_count(results),
              processing_time: calculate_processing_time
            }
          end
      end
    end
  end
end