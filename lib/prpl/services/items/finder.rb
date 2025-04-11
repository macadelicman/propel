# lib/prpl/services/products/finder.rb
module Prpl
  module Services
    module Items
      class Finder
        attr_reader :options, :scope

        def self.find(scope:, **options)
          new(scope, options).find
        end

        def initialize(scope, options = {})
          @scope = scope
          @options = options
          @conditions = []
          validate_scope!
        end

        def find
          Prpl.logger.info "Finding products", context: search_context

          results = apply_filters

          Prpl::Result.success(
            data: results,
            metadata: build_metadata(results)
          )
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "Product finder error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Unexpected error in product finder: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Prpl::Result.error("Product finding failed", status: :internal_server_error)
        end

        private

          def apply_filters
            build_conditions
            execute_query
          end

          def build_conditions
            add_basic_search_condition if options[:query].present?
            add_category_condition if options[:category].present?
            add_vendor_condition if options[:vendor].present?
            add_type_condition if options[:type].present?
            add_status_condition if options[:status].present?
            add_published_condition if options[:published].present?
            add_price_conditions if price_filter_present?
            add_stock_condition if options[:in_stock].present?
          end

          def execute_query
            if scope.respond_to?(:where)
              execute_active_record_query
            else
              execute_enumerable_query
            end
          end

          def execute_active_record_query
            query = scope.order(:title)

            if @conditions.any?
              conditions_sql = @conditions.map(&:shift).join(' AND ')
              query = query.where(conditions_sql, @conditions.flatten.to_h)
            end

            query = query.joins(:variants) if requires_variant_join?
            query.distinct
          end

          def execute_enumerable_query
            results = scope.select do |product|
              @conditions.all? do |condition|
                evaluate_condition(product, condition)
              end
            end

            results.sort_by { |p| p.respond_to?(:title) ? p.title : '' }
          end

          def add_basic_search_condition
            if scope.respond_to?(:where)
              @conditions << [
                %w[
                title ILIKE :query
                handle ILIKE :query
                vendor ILIKE :query
                product_category ILIKE :query
                product_type ILIKE :query
                variants.variant_sku ILIKE :query
              ].join(' OR '),
                { query: "%#{options[:query]}%" }
              ]
            else
              @conditions << [:basic_search, options[:query]]
            end
          end

          def add_category_condition
            add_condition(:product_category, options[:category])
          end

          def add_vendor_condition
            add_condition(:vendor, options[:vendor])
          end

          def add_type_condition
            add_condition(:product_type, options[:type])
          end

          def add_status_condition
            add_condition(:status, options[:status])
          end

          def add_published_condition
            add_condition(:published, options[:published])
          end

          def add_price_conditions
            if scope.respond_to?(:where)
              @conditions << [
                'variants.variant_price >= :min_price AND variants.variant_price <= :max_price',
                {
                  min_price: options[:min_price] || 0,
                  max_price: options[:max_price] || Float::INFINITY
                }
              ]
            else
              @conditions << [:price_range, options[:min_price], options[:max_price]]
            end
          end

          def add_stock_condition
            if scope.respond_to?(:where)
              @conditions << ['variants.variant_inventory_quantity > 0', {}]
            else
              @conditions << [:in_stock]
            end
          end

          def add_condition(field, value)
            if scope.respond_to?(:where)
              @conditions << ["#{field} = :#{field}", { field => value }]
            else
              @conditions << [field, value]
            end
          end

          def evaluate_condition(product, condition)
            case condition[0]
              when :basic_search
                search_term = condition[1].downcase
                searchable_attributes(product).any? do |attr|
                  value = get_product_attribute(product, attr)
                  value.to_s.downcase.include?(search_term)
                end
              when :price_range
                min_price, max_price = condition[1], condition[2]
                product_prices = get_variant_prices(product)
                product_prices.any? { |price| price >= min_price && price <= max_price }
              when :in_stock
                product_in_stock?(product)
              else
                product_matches_condition?(product, condition)
            end
          end

          def searchable_attributes(product)
            [
              :title,
              :handle,
              :vendor,
              :product_category,
              :product_type,
              :variant_skus
            ]
          end

          def get_product_attribute(product, attr)
            if attr == :variant_skus && product.respond_to?(:variants)
              product.variants.map(&:variant_sku).join(" ")
            elsif product.respond_to?(attr)
              product.public_send(attr)
            else
              ""
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

          def product_matches_condition?(product, condition)
            field, value = condition
            product.respond_to?(field) && product.public_send(field) == value
          end

          def price_filter_present?
            options[:min_price].present? || options[:max_price].present?
          end

          def requires_variant_join?
            price_filter_present? ||
              options[:in_stock].present? ||
              (options[:query].present? && scope.respond_to?(:joins))
          end

          def validate_scope!
            unless scope
              raise Prpl::Errors::Error, "Scope must be provided"
            end
          end

          def build_metadata(results)
            {
              total_results: get_result_count(results),
              filters_applied: active_filters,
              query: options[:query]
            }
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
            options.slice(
              :category,
              :vendor,
              :type,
              :status,
              :published,
              :min_price,
              :max_price,
              :in_stock
            ).compact
          end

          def search_context
            {
              query: options[:query],
              filters: active_filters,
              scope_type: scope.class.name
            }
          end
      end
    end
  end
end