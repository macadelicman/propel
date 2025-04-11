# lib/prpl/services/products/filter.rb
module Prpl
  module Services
    module Items
      class Filter
        attr_reader :scope, :criteria

        def self.apply(scope:, **criteria)
          new(scope, criteria).apply
        end

        def initialize(scope, criteria = {})
          @scope = scope
          @criteria = criteria
          validate_scope!
        end

        def apply
          Prpl.logger.info "Applying filters", context: filter_context

          filtered_results = apply_filters

          Prpl::Result.success(
            data: filtered_results,
            metadata: build_metadata(filtered_results)
          )
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "Filter error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Unexpected error in filter: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Prpl::Result.error("Filtering failed", status: :internal_server_error)
        end

        private

          def apply_filters
            result = scope

            result = apply_category_filter(result)
            result = apply_vendor_filter(result)
            result = apply_type_filter(result)
            result = apply_status_filter(result)
            result = apply_published_filter(result)
            result = apply_price_filter(result)
            result = apply_stock_filter(result)

            result
          end

          def apply_category_filter(result)
            return result unless criteria[:category]

            filter_by_attribute(result, :product_category, criteria[:category])
          end

          def apply_vendor_filter(result)
            return result unless criteria[:vendor]

            filter_by_attribute(result, :vendor, criteria[:vendor])
          end

          def apply_type_filter(result)
            return result unless criteria[:type]

            filter_by_attribute(result, :product_type, criteria[:type])
          end

          def apply_status_filter(result)
            return result unless criteria[:status]

            filter_by_attribute(result, :status, criteria[:status])
          end

          def apply_published_filter(result)
            return result unless criteria[:published]

            filter_by_attribute(result, :published, criteria[:published])
          end

          def apply_price_filter(result)
            return result unless price_filter_needed?

            min_price = criteria[:min_price].presence || 0
            max_price = criteria[:max_price].presence || Float::INFINITY

            if result.respond_to?(:joins)
              result.joins(:variants)
                    .where('variants.variant_price >= ? AND variants.variant_price <= ?',
                           min_price, max_price)
            else
              result.select do |product|
                product_prices = get_variant_prices(product)
                product_prices.any? { |price| price >= min_price && price <= max_price }
              end
            end
          end

          def apply_stock_filter(result)
            return result unless criteria[:in_stock]

            if result.respond_to?(:joins)
              result.joins(:variants)
                    .where('variants.variant_inventory_quantity > 0')
            else
              result.select { |product| product_in_stock?(product) }
            end
          end

          def filter_by_attribute(result, attribute, value)
            if result.respond_to?(:where)
              result.where(attribute => value)
            else
              result.select do |product|
                product.respond_to?(attribute) &&
                  product.public_send(attribute) == value
              end
            end
          end

          def get_variant_prices(product)
            return [] unless product.respond_to?(:variants)

            product.variants.map do |variant|
              variant.respond_to?(:variant_price) ? variant.variant_price : 0
            end
          end

          def product_in_stock?(product)
            return false unless product.respond_to?(:variants)

            product.variants.any? do |variant|
              variant.respond_to?(:variant_inventory_quantity) &&
                variant.variant_inventory_quantity.to_i.positive?
            end
          end

          def price_filter_needed?
            criteria[:min_price].present? || criteria[:max_price].present?
          end

          def validate_scope!
            unless scope
              raise Prpl::Errors::Error, "Scope must be provided"
            end
          end

          def build_metadata(results)
            {
              applied_filters: active_filters,
              total_filtered: get_result_count(results),
              price_range: price_range_info
            }.compact
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

          def active_filters
            criteria.slice(
              :category,
              :vendor,
              :type,
              :status,
              :published,
              :in_stock
            ).merge(price_filter_info).compact
          end

          def price_filter_info
            return {} unless price_filter_needed?

            {
              price_filter: {
                min: criteria[:min_price],
                max: criteria[:max_price]
              }
            }
          end

          def price_range_info
            return nil unless price_filter_needed?

            {
              min: criteria[:min_price] || 0,
              max: criteria[:max_price] || 'unlimited'
            }
          end

          def filter_context
            {
              scope_type: scope.class.name,
              filters: active_filters
            }
          end
      end
    end
  end
end