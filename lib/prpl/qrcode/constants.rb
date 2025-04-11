module Prpl
  module Qrcode
    module Constants
      COLORS = {
        'R'  => 'Red',
        'Bl' => 'Blue',
        'Y'  => 'Yellow',
        'G'  => 'Green',
        'P'  => 'Purple',
        'O'  => 'Orange',
        'Br' => 'Brown',
        'Bk' => 'Black'
      }.freeze

      SIZES = {
        'SM' => 'Small',
        'MD' => 'Medium',
        'LG' => 'Large',
        'XL' => 'Extra Large'
      }.freeze

      VALID_VARIANTS = COLORS.keys.product(SIZES.keys).map { |color, size| "#{color}-#{size}" }.freeze
    end
  end
end