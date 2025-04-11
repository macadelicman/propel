module Prpl
  module Services
    module Inventory
      class Adjuster
        attr_reader :variant, :quantity, :options

        def self.adjust(variant:, quantity:, **options)
          new(variant, quantity, options).adjust
        end

        def self.adjust_by_identifier(identifier:, quantity:, variant_finder:, **options)
          new(nil, quantity, options.merge(
            identifier: identifier,
            variant_finder: variant_finder
          )).adjust_by_identifier
        end

        def initialize(variant, quantity, options = {})
          @variant = variant
          @quantity = quantity.to_i
          @options = options
          @identifier = options[:identifier]
          @variant_finder = options[:variant_finder]
        end

        def adjust
          Prpl.logger.info "Adjusting inventory", context: adjustment_context

          validate_quantity!

          new_quantity = calculate_new_quantity
          update_inventory(new_quantity)

          build_success_result(new_quantity)
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "Validation error: #{e.message}"
          Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Adjustment failed: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Result.error("Error adjusting inventory: #{e.message}", status: :internal_server_error)
        end

        def adjust_by_identifier
          Prpl.logger.info "Looking up variant by identifier: #{@identifier}"

          find_variant
          adjust
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "Variant lookup failed: #{e.message}"
          Result.error(e.message, status: :not_found)
        end

        private

          def validate_quantity!
            unless quantity.is_a?(Integer)
              raise Prpl::Errors::Error, "Quantity must be an integer"
            end
          end

          def find_variant
            raise Prpl::Errors::Error, "No variant finder provided" unless @variant_finder

            @variant = @variant_finder.call(@identifier)

            unless @variant
              raise Prpl::Errors::Error, "Variant not found for identifier: #{@identifier}"
            end
          end

          def calculate_new_quantity
            current = current_quantity
            new_quantity = current + quantity

            # Ensure it doesn't go below zero, maintaining original behavior
            if new_quantity.negative?
              Prpl.logger.warn "Adjustment would result in negative inventory, setting to 0",
                               context: { original: current, adjustment: quantity }
              0
            else
              new_quantity
            end
          end

          def current_quantity
            return 0 unless variant.respond_to?(:variant_inventory_quantity)

            quantity = variant.variant_inventory_quantity
            quantity.is_a?(Integer) ? quantity : 0
          end

          def update_inventory(new_quantity)
            return false unless variant.respond_to?(:update_inventory_quantity)

            if variant.update_inventory_quantity(new_quantity)
              Prpl.logger.info "Successfully updated inventory",
                               context: { new_quantity: new_quantity }
              true
            else
              raise Prpl::Errors::Error, "Failed to update inventory"
            end
          end

          def build_success_result(new_quantity)
            Result.success(
              data: {
                variant_sku: variant_sku,
                adjustment: quantity,
                new_quantity: new_quantity
              },
              metadata: {
                timestamp: Time.now,
                identifier: @identifier
              }
            )
          end

          def variant_sku
            return nil unless variant
            variant.respond_to?(:variant_sku) ? variant.variant_sku : nil
          end

          def adjustment_context
            {
              variant_sku: variant_sku,
              adjustment: quantity,
              current_quantity: current_quantity
            }
          end
      end
    end
  end
end