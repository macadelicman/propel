# lib/prpl/pdf/base_generator.rb
module Prpl
  module Pdf
    class BaseGenerator
      POINTS_PER_INCH = 72

      # Formats a price float into a currency string
      def self.format_price(value)
        return "$0.00" unless value
        "$#{'%.2f' % value}"
      end

      # Sanitizes and converts a gap value to float
      def self.sanitize_gap(value)
        Float(value)
      rescue ArgumentError, TypeError
        0.05 # default fallback
      end
    end
  end
end
