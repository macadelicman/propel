require 'logger'
require 'securerandom'
require 'set'
require 'json'
require_relative 'prpl/version'
require_relative 'prpl/utils'
require_relative 'prpl/services'
require_relative 'prpl/inventory'
require_relative 'prpl/pdf'
require_relative 'prpl/items'

module Prpl
  autoload :Version, 'prpl/version'

  module Services
    module Items
      autoload :SyncService, 'prpl/services/items/sync_service'
    end
  end

  module Config
    module Templates
      module Products
        module Queries
          autoload :GetAllProducts, 'prpl/config/templates/products/queries/get_all_products'
        end
      end
    end
  end
end

# Register Roda plugins
if defined?(Roda)
  require_relative 'prpl/plugins/roda/item_sync'
end