# lib/prpl/inventory/adjuster.rb
module Prpl
  module Inventory
    class Adjuster
      # Processes a single command string for inventory adjustment
      # Returns a result message string
      def self.process_command(command)
        parsed = Prpl::Inventory::Parser.parse_command(command)
        return parsed[:error] if parsed[:error]
        quantity = parsed[:quantity]
        identifier = parsed[:identifier]
        variant = find_variant(identifier)
        return "Variant not found for identifier: #{identifier}." unless variant
        begin
          new_quantity = variant.variant_inventory_quantity + quantity
          new_quantity = 0 if new_quantity.negative?
          variant.update!(variant_inventory_quantity: new_quantity)
          "Successfully adjusted inventory by #{quantity} for SKU: #{variant.variant_sku}. New quantity: #{new_quantity}."
        rescue => e
          "Error adjusting inventory: #{e.message}"
        end
      end

      # Processes multiple command strings
      # Returns an array of result message strings
      def self.process_commands(commands)
        parsed = Prpl::Inventory::Parser.parse_commands(commands)
        return [parsed[:error]] if parsed[:error]
        commands.map do |cmd|
          process_command(cmd)
        end
      end

      private

        # Finds a variant by SKU, UUID, or Title
        def self.find_variant(identifier)
          Prpl::Models::Variant.find_by(variant_sku: identifier) ||
            Prpl::Models::Variant.find_by(uuid: identifier) ||
            Prpl::Models::Variant.joins(:product).find_by("prpl_products.title ILIKE ?", "%#{identifier}%")
        end
    end
  end
end
