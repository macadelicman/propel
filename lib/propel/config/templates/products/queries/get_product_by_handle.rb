require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module Products
        module Queries
          class GetProductByHandle
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetProductByHandle($handle: String!) {
                productByHandle(handle: $handle) {
                  id
                  title
                  descriptionHtml
                  handle
                  media(first: 5) {
                    edges {
                      node {
                        ... on MediaImage {
                          id
                          alt
                          image {
                            url
                          }
                        }
                        ... on Video {
                          id
                          alt
                          previewImage {
                            url
                          }
                        }
                      }
                    }
                  }
                  options {
                    id
                    name
                    values
                  }
                  variants(first: 10) {
                    edges {
                      node {
                        id
                        title
                        sku
                        inventoryQuantity
                        selectedOptions {
                          name
                          value
                        }
                      }
                    }
                  }
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetProductByHandle query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a product by its handle.
            #
            # @param handle [String] The handle of the product.
            # @return [Hash, nil] The structured product data or nil if not found.
            def fetch_product(handle)
              variables = { 'handle' => handle }
              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              response.body.dig('data', 'productByHandle')
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
  require_relative 'get_product_by_handle'  # Adjust the path as needed

  # Setup Shopify session and GraphQL client
  session = ShopifyAPI::Auth::Session.new(
    shop: 'your-development-store.myshopify.com',
    access_token: 'your_access_token_here'
  )
  client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

  # Instantiate and use the GetProductByHandle class
  product_handle = 'winter-hat'  # Replace with your product handle
  product_query = Propel::Config::Templates::Products::Queries::GetProductByHandle.new(client)
  product = product_query.fetch_product(product_handle)

  if product
    puts "Product Title: #{product['title']}"
    puts "Description: #{product['descriptionHtml']}"
  else
    puts "Product with handle '#{product_handle}' not found."
  end
=end
