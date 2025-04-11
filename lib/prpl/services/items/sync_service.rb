# frozen_string_literal: true
# lib/prpl/services/items/sync_service.rb

require 'logger'
require 'set'
require 'securerandom'
require 'sequel'

module Prpl
  module Services
    module Items
      class SyncService
        attr_reader :logger

        def initialize(logger: Logger.new($stdout))
          @logger = logger
        end

        def sync(items_data)
          items = extract_items(items_data)

          if items.empty?
            return { status: "error", message: "No items provided" }
          end

          results = initialize_results

          # Use a per-item transaction so that errors on one item do not abort the entire batch.
          items.each do |item_data|
            begin
              DB.transaction { process_item_sync(item_data, results) }
            rescue => e
              handle_sync_error(results, item_data, e)
            end
          end

          render_sync_results(results)
        end

        def fetch_shopify_items
          shop = ENV['SHOP']
          access_token = ENV['ADMIN_API_ACCESS_TOKEN']
          unless shop && access_token && !access_token.empty?
            raise "Missing SHOP or ADMIN_API_ACCESS_TOKEN in environment variables."
          end

          logger.info "Using shop: #{shop} with API version #{ShopifyAPI::Context.api_version}"
          session = ShopifyAPI::Auth::Session.new(shop: shop, access_token: access_token)
          client  = ShopifyAPI::Clients::Graphql::Admin.new(session: session)
          products_query = Prpl::Config::Templates::Products::Queries::GetAllProducts.new(client)
          items = products_query.fetch_all
          logger.info "Fetched #{items.size} products from Shopify"
          items
        end

        private

        def extract_items(params)
          if params["items"] && !params["items"].empty?
            params["items"]
          elsif params["item"] && !params["item"].empty?
            [params["item"]]
          elsif params.keys.any?
            [params]
          else
            []
          end
        end

        def validate_item_data(item_data)
          # Basic fields required for all items
          required_fields = %w[id title]

          missing_fields = required_fields.select do |field|
            value = item_data[field]
            value.nil? || value.to_s.strip.empty?
          end

          unless missing_fields.empty?
            raise "Required item field(s) missing: #{missing_fields.join(', ')}"
          end
        end

        def initialize_results
          {
            total_processed: 0,
            success_count: 0,
            error_count: 0,
            errors: [],
            categories_synced: Set.new,
            barcodes_synced: [],
            status: "success"
          }
        end

        def process_item_sync(item_data, results)
          results[:total_processed] += 1
          product_id = item_data["shopify_item_id"] || item_data["id"]
          logger.info "Starting sync for item #{product_id}"

          # Validate the required product fields.
          validate_item_data(item_data)

          # Sync item directly to database
          item_id = sync_item_to_db(item_data)

          # Sync images (if available)
          if item_data["images"] && !item_data["images"].empty?
            sync_images_to_db(item_id, item_data["images"])
          end

          # If we have variants, sync them
          if item_data["variants"] && !item_data["variants"].empty?
            sync_variants_to_db(item_id, item_data["variants"])
          end

          results[:categories_synced] << {
            item_type: item_data["item_type"] || "",
            item_category: item_data["item_category"] || "Default",
            vendor: item_data["vendor"] || "Unknown"
          }

          results[:success_count] += 1
          logger.info "Successfully synced item #{product_id}"
        rescue => e
          handle_sync_error(results, item_data, e)
        end

        def sync_images_to_db(item_id, images)
          # Remove any existing images for this product
          DB[:product_images].where(item_id: item_id).delete
          images.each do |url|
            begin
              DB[:product_images].insert(
                id: SecureRandom.uuid,
                item_id: item_id,
                url: url,
                created_at: Time.now,
                updated_at: Time.now
              )
              logger.info "Inserted image #{url} for item #{item_id}"
            rescue => e
              logger.error "Error inserting image for item #{item_id}: #{e.message}"
            end
          end
        end

        def sync_item_to_db(item_data)
          product_id = item_data["shopify_item_id"] || item_data["id"]

          # Set defaults for missing values
          handle = item_data["handle"] || product_id.to_s.split('/').last

          # Check if item exists by shopify_item_id
          existing_item = DB[:items].where(shopify_item_id: product_id).first

          # If not found, check by handle
          if !existing_item
            existing_item = DB[:items].where(handle: handle).first
          end

          # Create item attributes hash
          item_attributes = {
            title: item_data["title"],
            handle: handle,
            status: item_data["status"] || "active",
            published: item_data["published"] || false,
            item_type: item_data["item_type"] || item_data["product_type"] || "", # Can be empty
            item_category: item_data["item_category"] || item_data["product_category"] || "Default",
            vendor: item_data["vendor"] || "Unknown",
            tags: Sequel.pg_array(Array(item_data["tags"]), :text),
            online_store_url: item_data["online_store_url"],
            online_store_preview_url: item_data["online_store_preview_url"],
            body_html: item_data["descriptionHtml"], # Save the HTML description to body_html
            synced_at: Time.now,
            raw_category_data: Sequel.pg_jsonb({
                                                 "item_type" => item_data["item_type"] || item_data["product_type"] || "",
                                                 "item_category" => item_data["item_category"] || item_data["product_category"] || "Default",
                                                 "vendor" => item_data["vendor"] || "Unknown",
                                                 "tags" => Array(item_data["tags"]),
                                                 "received_at" => Time.now.to_s
                                               })
          }

          if existing_item
            # Update the existing item
            item_id = existing_item[:id]
            DB[:items].where(id: item_id).update(item_attributes.merge(updated_at: Time.now))
            logger.info "Updated existing item #{item_id}"
            return item_id
          else
            # Create a new item
            item_id = SecureRandom.uuid
            DB[:items].insert(item_attributes.merge(
              id: item_id,
              shopify_item_id: product_id,
              created_at: Time.now,
              updated_at: Time.now
            ))
            logger.info "Created new item #{item_id}"
            return item_id
          end
        end

        def sync_variants_to_db(item_id, variants_data)
          return unless variants_data && !variants_data.empty?

          variants_data.each do |variant_data|
            begin
              variant_id = variant_data["id"]
              sku = variant_data["sku"] || ""

              # Skip variants without IDs
              next if variant_id.nil? || variant_id.empty?

              # Check if the variant exists
              existing_variant = DB[:product_variants].where(shopify_variant_id: variant_id).first

              # If not found by ID, try by SKU
              if !existing_variant && !sku.empty?
                existing_variant = DB[:product_variants].where(item_id: item_id, sku: sku).first
              end

              variant_attributes = {
                title: variant_data["title"] || "Default Title",
                sku: sku,
                inventory_quantity: variant_data["inventoryQuantity"] || 0
              }

              if existing_variant
                # Update existing variant
                DB[:product_variants].where(id: existing_variant[:id]).update(
                  variant_attributes.merge(updated_at: Time.now)
                )
                logger.info "Updated variant #{existing_variant[:id]}"

                # Sync selected options
                if variant_data["selectedOptions"] && !variant_data["selectedOptions"].empty?
                  sync_selected_options(existing_variant[:id], variant_data["selectedOptions"])
                end
              else
                # Create new variant
                new_variant_id = SecureRandom.uuid
                DB[:product_variants].insert(
                  variant_attributes.merge(
                    id: new_variant_id,
                    item_id: item_id,
                    shopify_variant_id: variant_id,
                    created_at: Time.now,
                    updated_at: Time.now
                  )
                )
                logger.info "Created new variant #{new_variant_id}"

                # Sync selected options
                if variant_data["selectedOptions"] && !variant_data["selectedOptions"].empty?
                  sync_selected_options(new_variant_id, variant_data["selectedOptions"])
                end
              end
            rescue => e
              logger.error "Error syncing variant: #{e.message}"
            end
          end
        end

        def sync_selected_options(variant_id, options_data)
          return unless options_data && !options_data.empty?

          # Delete existing options for this variant
          DB[:variant_selected_options].where(product_variant_id: variant_id).delete

          # Insert new options
          options_data.each do |option|
            next unless option["name"] && option["value"]

            begin
              DB[:variant_selected_options].insert(
                id: SecureRandom.uuid,
                product_variant_id: variant_id,
                name: option["name"],
                value: option["value"],
                created_at: Time.now,
                updated_at: Time.now
              )
            rescue => e
              logger.error "Error syncing option: #{e.message}"
            end
          end
        end

        def handle_sync_error(results, item_data, error)
          results[:error_count] += 1
          results[:status] = "error"
          error_details = {
            shopify_item_id: item_data["shopify_item_id"] || item_data["id"],
            error: error.message
          }
          logger.error "Error syncing item #{item_data['shopify_item_id'] || item_data['id']}: #{error.message}"
          results[:errors] << error_details
        end

        def render_sync_results(results)
          {
            status: results[:status],
            message: sync_status_message(results),
            details: {
              total_processed: results[:total_processed],
              success_count: results[:success_count],
              error_count: results[:error_count],
              errors: results[:errors],
              categories_synced: results[:categories_synced].to_a,
              barcodes_synced: results[:barcodes_synced]
            }
          }
        end

        def sync_status_message(results)
          if results[:error_count] > 0 && results[:success_count] > 0
            "Synced #{results[:success_count]} items with #{results[:error_count]} errors"
          elsif results[:success_count] > 0
            "Successfully synced #{results[:success_count]} items"
          else
            "Failed to sync items"
          end
        end
      end
    end
  end
end