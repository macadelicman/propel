require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Prpl
  module Config
    module Templates
      module Products
        module Queries
          class GetProductVariantById
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetProductVariantById($variantId: ID!) {
                productVariant(id: $variantId) {
                  id
                  title
                  sku
                  inventoryQuantity
                  price
                  compareAtPrice
                  selectedOptions {
                    name
                    value
                  }
                  product {
                    id
                    title
                  }
                  media(first: 10) {
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
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetProductVariantById query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a product variant by its Shopify GraphQL ID.
            #
            # @param variant_id [String] The Shopify GraphQL ID of the product variant.
            # @return [Hash, nil] The structured variant data or nil if not found.
            def fetch_variant(variant_id)
              variables = { 'variantId' => variant_id }
              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              response.body.dig('data', 'productVariant')
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
  require_relative 'get_product_variant_by_id'  # Adjust the path as needed

  # Setup Shopify session and GraphQL client
  session = ShopifyAPI::Auth::Session.new(
    shop: 'your-development-store.myshopify.com',
    access_token: 'your_access_token_here'
  )
  client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

  # Instantiate and use the GetProductVariantById class
  variant_id = 'gid://shopify/ProductVariant/1234567890'  # Replace with your variant ID
  variant_query = Prpl::Config::Templates::Products::Queries::GetProductVariantById.new(client)
  variant = variant_query.fetch_variant(variant_id)

  if variant
    puts "Variant Title: #{variant['title']}"
    puts "SKU: #{variant['sku']}"
    puts "Price: #{variant['price']}"
  else
    puts "Variant with ID '#{variant_id}' not found."
  end
=end
