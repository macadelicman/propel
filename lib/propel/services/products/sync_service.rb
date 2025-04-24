# frozen_string_literal: true
# lib/propel/services/products/sync_service.rb

require 'logger'
require 'set'
require 'securerandom'
require 'sequel'

module Propel
  module Services
    module Products
      class SyncService
        attr_reader :logger

        def initialize(logger: Logger.new($stdout))
          @logger = logger
        end

        def sync(products_data)
          products = extract_products(products_data)

          if products.empty?
            return { status: "error", message: "No products provided" }
          end

          results = initialize_results

          # Use a per-product transaction so that errors on one product do not abort the entire batch.
          products.each do |product_data|
            begin
              DB.transaction { process_product_sync(product_data, results) }
            rescue => e
              handle_sync_error(results, product_data, e)
            end
          end

          render_sync_results(results)
        end

        def fetch_shopify_products
          shop = ENV['SHOP']
          access_token = ENV['ADMIN_API_ACCESS_TOKEN']
          unless shop && access_token && !access_token.empty?
            raise "Missing SHOP or ADMIN_API_ACCESS_TOKEN in environment variables."
          end

          logger.info "Using shop: #{shop} with API version #{ShopifyAPI::Context.api_version}"
          session = ShopifyAPI::Auth::Session.new(shop: shop, access_token: access_token)
          client  = ShopifyAPI::Clients::Graphql::Admin.new(session: session)
          products_query = Propel::Config::Templates::Products::Queries::GetAllProducts.new(client)
          products = products_query.fetch_all
          logger.info "Fetched #{products.size} products from Shopify"
          products
        end

        private

        def extract_products(params)
          if params["products"] && !params["products"].empty?
            params["products"]
          elsif params["product"] && !params["product"].empty?
            [params["product"]]
          elsif params.keys.any?
            [params]
          else
            []
          end
        end

        def validate_product_data(product_data)
          # Basic fields required for all products
          required_fields = %w[id title]

          missing_fields = required_fields.select do |field|
            value = product_data[field]
            value.nil? || value.to_s.strip.empty?
          end

          unless missing_fields.empty?
            raise "Required product field(s) missing: #{missing_fields.join(', ')}"
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

        def process_product_sync(product_data, results)
          results[:total_processed] += 1
          product_id = product_data["shopify_product_id"] || product_data["id"]
          logger.info "Starting sync for product #{product_id}"

          # Validate the required product fields.
          validate_product_data(product_data)

          # Sync product directly to database
          product_id = sync_product_to_db(product_data)

          # Sync images (if available)
          if product_data["images"] && !product_data["images"].empty?
            sync_images_to_db(product_id, product_data["images"])
          end

          # If we have variants, sync them
          if product_data["variants"] && !product_data["variants"].empty?
            sync_variants_to_db(product_id, product_data["variants"])
          end

          results[:categories_synced] << {
            product_type: product_data["product_type"] || "",
            product_category: product_data["product_category"] || "Default",
            vendor: product_data["vendor"] || "Unknown"
          }

          results[:success_count] += 1
          logger.info "Successfully synced product #{product_id}"
        rescue => e
          handle_sync_error(results, product_data, e)
        end

        def sync_images_to_db(product_id, images)
          # Remove any existing images for this product
          DB[:product_images].where(product_id: product_id).delete
          images.each do |url|
            begin
              DB[:product_images].insert(
                id: SecureRandom.uuid,
                product_id: product_id,
                url: url,
                created_at: Time.now,
                updated_at: Time.now
              )
              logger.info "Inserted image #{url} for product #{product_id}"
            rescue => e
              logger.error "Error inserting image for product #{product_id}: #{e.message}"
            end
          end
        end

        def sync_product_to_db(product_data)
          product_id = product_data["shopify_product_id"] || product_data["id"]

          # Set defaults for missing values
          handle = product_data["handle"] || product_id.to_s.split('/').last

          # Check if product exists by shopify_product_id
          existing_product = DB[:products].where(shopify_product_id: product_id).first

          # If not found, check by handle
          if !existing_product
            existing_product = DB[:products].where(handle: handle).first
          end

          # Create product attributes hash
          product_attributes = {
            title: product_data["title"],
            handle: handle,
            status: product_data["status"] || "active",
            published: product_data["published"] || false,
            product_type: product_data["product_type"] || product_data["product_type"] || "", # Can be empty
            product_category: product_data["product_category"] || product_data["product_category"] || "Default",
            vendor: product_data["vendor"] || "Unknown",
            tags: Sequel.pg_array(Array(product_data["tags"]), :text),
            online_store_url: product_data["online_store_url"],
            online_store_preview_url: product_data["online_store_preview_url"],
            body_html: product_data["descriptionHtml"], # Save the HTML description to body_html
            synced_at: Time.now,
            raw_category_data: Sequel.pg_jsonb({
                                                 "product_type" => product_data["product_type"] || product_data["product_type"] || "",
                                                 "product_category" => product_data["product_category"] || product_data["product_category"] || "Default",
                                                 "vendor" => product_data["vendor"] || "Unknown",
                                                 "tags" => Array(product_data["tags"]),
                                                 "received_at" => Time.now.to_s
                                               })
          }

          if existing_product
            # Update the existing product
            product_id = existing_product[:id]
            DB[:products].where(id: product_id).update(product_attributes.merge(updated_at: Time.now))
            logger.info "Updated existing product #{product_id}"
            return product_id
          else
            # Create a new product
            product_id = SecureRandom.uuid
            DB[:products].insert(product_attributes.merge(
              id: product_id,
              shopify_product_id: product_id,
              created_at: Time.now,
              updated_at: Time.now
            ))
            logger.info "Created new product #{product_id}"
            return product_id
          end
        end

        def sync_variants_to_db(product_id, variants_data)
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
                existing_variant = DB[:product_variants].where(product_id: product_id, sku: sku).first
              end

              variant_attributes = {
                title: variant_data["title"] || "Default Title",
                sku: sku,
                inventory_quantity: variant_data["inventoryQuantity"] || 0,
                price: variant_data["price"] || 0.0  # Added price field with default 0.0
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
                    product_id: product_id,
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

        def handle_sync_error(results, product_data, error)
          results[:error_count] += 1
          results[:status] = "error"
          error_details = {
            shopify_product_id: product_data["shopify_product_id"] || product_data["id"],
            error: error.message
          }
          logger.error "Error syncing product #{product_data['shopify_product_id'] || product_data['id']}: #{error.message}"
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
            "Synced #{results[:success_count]} products with #{results[:error_count]} errors"
          elsif results[:success_count] > 0
            "Successfully synced #{results[:success_count]} products"
          else
            "Failed to sync products"
          end
        end
      end
    end
  end
end