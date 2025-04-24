# frozen_string_literal: true
# lib/propel/plugins/roda/product_sync.rb

require 'roda'
require_relative '../../services/products/sync_service'

class Roda
  module RodaPlugins
    # ProductSync plugin for Roda that provides a sync endpoint for products
    module PropelProductSync
      module InstanceMethods
        def product_sync_route
          route do |r|
            r.post "sync" do
              logger = env['rack.logger'] || Logger.new($stdout)
              sync_service = Propel::Services::Products::SyncService.new(logger: logger)

              begin
                if r.params.empty? || (r.params["products"].nil? && r.params["product"].nil? && r.params.keys.empty?)
                  # When no products provided, fetch from Shopify
                  products = sync_service.fetch_shopify_products
                  if products.empty?
                    response.status = 400
                    { status: "error", message: "No products provided or found in Shopify" }
                  else
                    results = sync_service.sync({ "products" => products })
                    response.status = results[:status] == "success" ? 200 : 207
                    results
                  end
                else
                  # Process products provided in request
                  results = sync_service.sync(r.params)
                  response.status = results[:status] == "success" ? 200 : 207
                  results
                end
              rescue => e
                logger.error "Sync endpoint failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
                response.status = 500
                { status: "error", message: "Internal Server Error", error: e.message }
              end
            end
          end
        end
      end

      def self.configure(app, opts = {})
        app.plugin :json
        app.plugin :all_verbs
      end
    end

    register_plugin(:propel_product_sync, PropelProductSync)
  end
end