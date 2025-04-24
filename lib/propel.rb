require 'logger'
require 'securerandom'
require 'set'
require 'json'
require_relative 'propel/version'
require_relative 'propel/utils'
require_relative 'propel/services'
require_relative 'propel/inventory'
require_relative 'propel/pdf'
require_relative 'propel/items'

module Propel
  autoload :Version, 'propel/version'

  module Services
    module Items
      autoload :SyncService, 'propel/services/items/sync_service'
    end
  end

  module Config
    module Templates
      module Products
        module Queries
          autoload :GetAllProducts, 'propel/config/templates/products/queries/get_all_products'
        end
      end
    end
  end
end

# Register Roda plugins
if defined?(Roda)
  require_relative 'propel/plugins/roda/item_sync'
end