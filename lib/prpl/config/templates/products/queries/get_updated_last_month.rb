require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'
require 'date'

module Prpl
  module Config
    module Templates
      module Products
        module Queries
          class GetUpdatedLastMonth
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetUpdatedLastMonth($query: String!, $first: Int! = 100, $cursor: String) {
                products(query: $query, first: $first, after: $cursor) {
                  edges {
                    cursor
                    node {
                      id
                      title
                      updatedAt
                      featuredMedia {
                        preview {
                          image {
                            url
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

            # Initializes the GetUpdatedLastMonth query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches products updated in the last month.
            #
            # @return [Array<Hash>] An array of transformed product nodes.
            def fetch_updated_last_month
              all_updated_products = []
              cursor = nil
              query_date = (Date.today << 1).strftime('%Y-%m-%d')  # Last month

              loop do
                variables = {
                  'query' => "updated_at:>#{query_date}",
                  'first' => 100,
                  'cursor' => cursor
                }
                response = client.query(query: GRAPHQL_QUERY, variables: variables)
                products_data = response.body.dig('data', 'products')
                break unless products_data && products_data['edges']

                # Transform each product to include the required fields
                products = products_data['edges'].map do |edge|
                  product = edge['node']

                  {
                    'id' => product['id'],
                    'title' => product['title'],
                    'updatedAt' => product['updatedAt'],
                    'featuredMediaUrl' => product.dig('featuredMedia', 'preview', 'image', 'url')
                  }
                end

                all_updated_products.concat(products)
                break unless products_data['pageInfo']['hasNextPage']

                cursor = products_data['pageInfo']['endCursor']
              end

              all_updated_products
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
  require 'date'
  require_relative 'get_updated_last_month'  # Adjust the path as needed

  # Setup Shopify session and GraphQL client
  session = ShopifyAPI::Auth::Session.new(
    shop: 'your-development-store.myshopify.com',
    access_token: 'your_access_token_here'
  )
  client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

  # Instantiate and use the GetUpdatedLastMonth class
  updated_products_query = Prpl::Config::Templates::Products::Queries::GetUpdatedLastMonth.new(client)
  updated_products = updated_products_query.fetch_updated_last_month

  puts "Products Updated in the Last Month: #{updated_products.size}"
  updated_products.each do |product|
    puts "ID: #{product['id']}, Title: #{product['title']}, Updated At: #{product['updatedAt']}"
    puts "Featured Media URL: #{product['featuredMediaUrl']}" if product['featuredMediaUrl']
    puts "----"
  end
=end
