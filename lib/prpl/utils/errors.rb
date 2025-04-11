module Prpl
  module Errors
    class Error < StandardError; end
    class InventoryError < Error; end
    class ValidationError < Error; end
    class NotFoundError < Error; end
  end
end
