# frozen_string_literal: true

require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module Products
        module Mutations
          module Bulk
            class ProductVariantsUpdate
              GRAPHQL_MUTATION = <<~GQL
                mutation ProductVariantsBulkUpdate($productId: ID!, $variants: [ProductVariantInput!]!) {
                  productVariantsBulkUpdate(productId: $productId, variants: $variants) {
                    product {
                      id
                    }
                    productVariants {
                      id
                      metafields(first: 2) {
                        edges {
                          node {
                            namespace
                            key
                            value
                          }
                        }
                      }
                    }
                    userErrors {
                      field
                      message
                    }
                  }
                }
              GQL

              attr_reader :client

              # Initializes the ProductVariantsUpdate mutation class with a GraphQL client.
              #
              # @param client [Object] A GraphQL client instance to execute mutations.
              def initialize(client)
                @client = client
              end

              # Updates product variants in bulk.
              #
              # @param product_id [String] The ID of the product to update variants for.
              # @param variants [Array<Hash>] An array of variant data to update.
              # @return [Hash] The parsed JSON response from the GraphQL API.
              def update(product_id:, variants:)
                variables = {
                  productId: product_id,
                  variants: variants
                }

                response = client.query(query: GRAPHQL_MUTATION, variables: variables)
                response.body
              end

              # Processes the response and returns a structured result.
              #
              # @param response [Hash] The raw response from the GraphQL API.
              # @return [Hash] A structured result with success status, product data, and any errors.
              def process_response(response)
                result = response.dig('data', 'productVariantsBulkUpdate')

                if result.nil?
                  return {
                    success: false,
                    errors: [{ message: 'Unknown error occurred' }],
                    product: nil,
                    variants: []
                  }
                end

                user_errors = result['userErrors'] || []
                product = result['product']
                variants = []

                if result['productVariants']
                  variants = result['productVariants'].map do |variant|
                    metafields = []

                    if variant['metafields'] && variant['metafields']['edges']
                      metafields = variant['metafields']['edges'].map do |edge|
                        node = edge['node']
                        {
                          'namespace' => node['namespace'],
                          'key' => node['key'],
                          'value' => node['value']
                        }
                      end
                    end

                    {
                      'id' => variant['id'],
                      'metafields' => metafields
                    }
                  end
                end

                {
                  success: user_errors.empty?,
                  errors: user_errors,
                  product: product,
                  variants: variants
                }
              end

              # Updates product variants and processes the response.
              #
              # @param product_id [String] The ID of the product to update variants for.
              # @param variants [Array<Hash>] An array of variant data to update.
              # @return [Hash] A structured result with success status, product data, and any errors.
              def update_and_process(product_id:, variants:)
                response = update(product_id: product_id, variants: variants)
                process_response(response)
              end
            end
          end
        end
      end
    end
  end
end
=begin
session = ShopifyAPI::Auth::Session.new(
  shop: 'your-development-store.myshopify.com',
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation ProductVariantsUpdate($productId: ID!) {
    productVariantsBulkUpdate(productId: $productId, variants: [{id: "gid://shopify/ProductVariant/1", barcode: "12345"}, {id: "gid://shopify/ProductVariant/2", barcode: "67890"}]) {
      product {
        id
      }
      productVariants {
        id
        metafields(first: 2) {
          edges {
            node {
              namespace
              key
              value
            }
          }
        }
      }
      userErrors {
        field
        message
      }
    }
  }
QUERY

variables = {
  "productId": 'gid://shopify/Product/20995642',
  "variants": [{'id'=>'gid://shopify/ProductVariant/1', 'barcode'=>'12345'}, {'id'=>'gid://shopify/ProductVariant/2', 'barcode'=>'67890'}]
}

response = client.query(query: query, variables: variables)
=end
# {
#   "productId": "gid://shopify/Product/20995642",
#   "variants": [
#     {
#       "id": "gid://shopify/ProductVariant/1",
#       "barcode": "12345"
#     },
#     {
#       "id": "gid://shopify/ProductVariant/2",
#       "barcode": "67890"
#     }
#   ]
# }

# Response #
# {
#   "productVariantsBulkUpdate": {
#     "product": {
#       "id": "gid://shopify/Product/20995642"
#     },
#     "productVariants": null,
#     "userErrors": [
#       {
#         "field": [
#           "variants",
#           "0",
#           "id"
#         ],
#         "message": "Product variant does not exist"
#       },
#       {
#         "field": [
#           "variants",
#           "1",
#           "id"
#         ],
#         "message": "Product variant does not exist"
#       }
#     ]
#   }
# }
