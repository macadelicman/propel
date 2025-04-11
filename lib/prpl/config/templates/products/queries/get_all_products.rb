require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Prpl
  module Config
    module Templates
      module Products
        module Queries
          class GetAllProducts
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetAllProducts($cursor: String) {
                products(first: 15, after: $cursor) {
                  edges {
                    cursor
                    node {
                      id
                      title
                      descriptionHtml
                      media(first: 5, sortKey: POSITION) {
                        edges {
                          node {
                            ... on MediaImage {
                              id
                              alt
                              image {
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
                  pageInfo {
                    hasNextPage
                    endCursor
                  }
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetAllProducts query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a single page of products.
            #
            # @param cursor [String, nil] The pagination cursor; pass nil for the first page.
            # @return [Hash] The parsed JSON response from the GraphQL API.
            def fetch_page(cursor: nil)
              response = client.query(query: GRAPHQL_QUERY, variables: { cursor: cursor })
              response.body
            end

            # Fetches all products using pagination.
            #
            # @return [Array<Hash>] An array of transformed product nodes.
            def fetch_all
              all_products = []
              cursor = nil

              loop do
                result = fetch_page(cursor: cursor)
                products_data = result.dig('data', 'products')
                break unless products_data && products_data['edges']

                # Transform each product to include the required fields
                products = products_data['edges'].map do |edge|
                  product = edge['node']

                  # Set default values for required fields
                  handle = product['id'].to_s.split('/').last
                  vendor = 'Shopify Store'
                  category = 'Default'

                  # Get media URLs
                  media_urls = []
                  if product['media'] && product['media']['edges']
                    media_urls = product['media']['edges'].map do |media_edge|
                      media_node = media_edge['node']
                      if media_node['image'] && media_node['image']['url']
                        media_node['image']['url']
                      else
                        nil
                      end
                    end.compact
                  end

                  # Extract variants
                  variants = []
                  if product['variants'] && product['variants']['edges']
                    variants = product['variants']['edges'].map do |variant_edge|
                      variant = variant_edge['node']

                      # Extract selected options
                      selected_options = []
                      if variant['selectedOptions']
                        selected_options = variant['selectedOptions'].map do |option|
                          {
                            'name' => option['name'],
                            'value' => option['value']
                          }
                        end
                      end

                      # Build variant hash
                      {
                        'id' => variant['id'],
                        'title' => variant['title'],
                        'sku' => variant['sku'],
                        'inventoryQuantity' => variant['inventoryQuantity'] || 0,
                        'selectedOptions' => selected_options
                      }
                    end
                  end

                  # Build final product hash
                  {
                    'id' => product['id'],
                    'shopify_item_id' => product['id'],
                    'title' => product['title'],
                    'descriptionHtml' => product['descriptionHtml'],
                    'handle' => handle,
                    'vendor' => vendor,
                    'item_type' => '',
                    'product_type' => '',
                    'item_category' => category,
                    'product_category' => category,
                    'status' => 'ACTIVE',
                    'published' => true,
                    'online_store_url' => nil,
                    'online_store_preview_url' => nil,
                    'tags' => [],
                    'variants' => variants,
                    'images' => media_urls
                  }
                end

                all_products.concat(products)
                break unless products_data['pageInfo']['hasNextPage']

                cursor = products_data['pageInfo']['endCursor']
              end

              all_products
            end
          end
        end
      end
    end
  end
end
