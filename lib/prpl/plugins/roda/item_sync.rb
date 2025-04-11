# frozen_string_literal: true
# lib/prpl/plugins/roda/item_sync.rb

require 'roda'
require_relative '../../services/items/sync_service'

class Roda
  module RodaPlugins
    # ItemSync plugin for Roda that provides a sync endpoint for items
    module PrplItemSync
      module InstanceMethods
        def item_sync_route
          route do |r|
            r.post "sync" do
              logger = env['rack.logger'] || Logger.new($stdout)
              sync_service = Prpl::Services::Items::SyncService.new(logger: logger)

              begin
                if r.params.empty? || (r.params["items"].nil? && r.params["item"].nil? && r.params.keys.empty?)
                  # When no items provided, fetch from Shopify
                  items = sync_service.fetch_shopify_items
                  if items.empty?
                    response.status = 400
                    { status: "error", message: "No items provided or found in Shopify" }
                  else
                    results = sync_service.sync({ "items" => items })
                    response.status = results[:status] == "success" ? 200 : 207
                    results
                  end
                else
                  # Process items provided in request
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

    register_plugin(:prpl_item_sync, PrplItemSync)
  end
end