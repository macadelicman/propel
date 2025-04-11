require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Prpl
  module Config
    module Templates
      module Inventory
        module Queries
          class GetStockOfProduct
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetStockOfProduct($productId: ID!) {
                product(id: $productId) {
                  id
                  title
                  variants(first: 100) {
                    edges {
                      node {
                        id
                        title
                        inventoryQuantity
                        inventoryItem {
                          id
                          tracked
                        }
                        inventoryLevels(first: 10) {
                          edges {
                            node {
                              available
                              location {
                                id
                                name
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetStockOfProduct query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches stock information for a given product.
            #
            # @param product_id [String] The Shopify GraphQL ID of the product.
            # @return [Hash, nil] The structured stock data or nil if not found.
            def fetch_stock(product_id)
              variables = { 'productId' => product_id }
              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              response.body.dig('data', 'product')
            end
          end
        end
      end
    end
  end
end

=begin
  require 'shopify_api'
  require 'graphql/client'
  require 'graphql/client/http'
  require_relative 'get_stock_of_product'  # Adjust the path as needed

  # Setup Shopify session and GraphQL client
  session = ShopifyAPI::Auth::Session.new(
    shop: 'your-development-store.myshopify.com',
    access_token: 'your_access_token_here'
  )
  client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

  # Instantiate and use the GetStockOfProduct class
  product_id = 'gid://shopify/Product/108828309'  # Replace with your product ID
  stock_query = Prpl::Config::Templates::Inventory::Queries::GetStockOfProduct.new(client)
  stock_data = stock_query.fetch_stock(product_id)

  if stock_data
    puts "Product Title: #{stock_data['title']}"
    stock_data['variants']['edges'].each do |edge|
      variant = edge['node']
      puts "Variant Title: #{variant['title']}"
      puts "Inventory Quantity: #{variant['inventoryQuantity']}"
      variant['inventoryLevels']['edges'].each do |level|
        inventory_level = level['node']
        puts "  Location: #{inventory_level['location']['name']}, Available: #{inventory_level['available']}"
      end
      puts "----"
    end
  else
    puts "Product with ID '#{product_id}' not found."
  end
=end
