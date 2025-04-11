require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Prpl
  module Config
    module Templates
      module Collections
        module Queries
          class GetAllCollections
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetAllCollections($cursor: String) {
                collections(first: 50, after: $cursor) {
                  edges {
                    cursor
                    node {
                      id
                      title
                      handle
                      updatedAt
                      sortOrder
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

            # Initializes the GetAllCollections query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a single page of collections.
            #
            # @param cursor [String, nil] The pagination cursor; pass nil for the first page.
            # @return [Hash] The parsed JSON response from the GraphQL API.
            def fetch_page(cursor: nil)
              response = client.query(query: GRAPHQL_QUERY, variables: { cursor: cursor })
              response.body
            end

            # Fetches all collections using pagination.
            #
            # @return [Array<Hash>] An array of transformed collection nodes.
            def fetch_all
              all_collections = []
              cursor = nil

              loop do
                result = fetch_page(cursor: cursor)
                collections_data = result.dig('data', 'collections')
                break unless collections_data && collections_data['edges']

                # Transform each collection to include the required fields
                collections = collections_data['edges'].map do |edge|
                  collection = edge['node']

                  {
                    'id' => collection['id'],
                    'title' => collection['title'],
                    'handle' => collection['handle'],
                    'updatedAt' => collection['updatedAt'],
                    'sortOrder' => collection['sortOrder']
                  }
                end

                all_collections.concat(collections)
                break unless collections_data['pageInfo']['hasNextPage']

                cursor = collections_data['pageInfo']['endCursor']
              end

              all_collections
            end
          end
        end
      end
    end
  end
end

=begin
### **Usage Example**

require 'shopify_api'
require 'graphql/client'
require 'graphql/client/http'
require_relative 'get_all_collections'  # Adjust the path as needed

# Setup Shopify session and GraphQL client
session = ShopifyAPI::Auth::Session.new(
  shop: 'your-development-store.myshopify.com',
  access_token: 'your_access_token_here'
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

# Instantiate and use the GetAllCollections class
collections_query = Prpl::Config::Templates::Collections::Queries::GetAllCollections.new(client)
all_collections = collections_query.fetch_all

puts "Total Collections: #{all_collections.size}"
puts all_collections

=end
