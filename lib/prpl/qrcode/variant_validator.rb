module Prpl
  module Qrcode
    class VariantValidator
      include Constants

      def initialize(variant)
        @variant = variant
        @inventory = ThnkInventory.find_by(sku: variant.variant_sku)
      end

      def valid?
        return false unless @inventory
        valid_format? && valid_color? && valid_size?
      end

      def variant_code
        return nil unless valid?
        "#{color_code}-#{size_code}"
      end

      private

        def valid_format?
          return false unless @inventory.option1_value && @inventory.option2_value
          VALID_VARIANTS.include?("#{color_code}-#{size_code}")
        end

        def valid_color?
          COLORS.key?(color_code)
        end

        def valid_size?
          SIZES.key?(size_code)
        end

        def color_code
          @inventory.option1_value.strip[0,2].upcase
        end

        def size_code
          @inventory.option2_value.strip[0,2].upcase
        end
    end
  end
end