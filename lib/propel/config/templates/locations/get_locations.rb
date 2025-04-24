require 'shopify_api'
require 'graphql'
require 'graphql-client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module Locations
        class GetLocations
          GRAPHQL_QUERY = <<~GQL.freeze
            query GetLocations($first: Int = 20, $cursor: String) {
              locations(first: $first, after: $cursor) {
                edges {
                  cursor
                  node {
                    id
                    name
                    address {
                      address1
                      address2
                      city
                      province
                      zip
                      country
                    }
                    isActive
                    fulfillsOnlineOrders
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

          # Initializes the GetLocations query class with a GraphQL client.
          #
          # @param client [Object] A GraphQL client instance to execute queries.
          def initialize(client)
            @client = client
          end

          # Fetches a single page of locations.
          #
          # @param first [Integer] Number of locations to fetch per page.
          # @param cursor [String, nil] The pagination cursor; pass nil for the first page.
          # @return [Hash] The parsed JSON response from the GraphQL API.
          def fetch_page(first: 20, cursor: nil)
            variables = {
              'first' => first,
              'cursor' => cursor
            }
            response = client.query(query: GRAPHQL_QUERY, variables: variables)
            response.body
          end

          # Fetches all locations using pagination.
          #
          # @return [Array<Hash>] An array of transformed location nodes.
          def fetch_all
            all_locations = []
            cursor = nil

            loop do
              result = fetch_page(cursor: cursor)
              locations_data = result.dig('data', 'locations')
              break unless locations_data && locations_data['edges']

              # Transform each location to include the required fields
              locations = locations_data['edges'].map do |edge|
                location = edge['node']

                {
                  'id' => location['id'],
                  'name' => location['name'],
                  'address1' => location.dig('address', 'address1'),
                  'address2' => location.dig('address', 'address2'),
                  'city' => location.dig('address', 'city'),
                  'province' => location.dig('address', 'province'),
                  'zip' => location.dig('address', 'zip'),
                  'country' => location.dig('address', 'country'),
                  'isActive' => location['isActive'],
                  'fulfillsOnlineOrders' => location['fulfillsOnlineOrders']
                }
              end

              all_locations.concat(locations)
              break unless locations_data['pageInfo']['hasNextPage']

              cursor = locations_data['pageInfo']['endCursor']
            end

            all_locations
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
  require_relative 'get_locations'  # Adjust the path as needed

  # Setup Shopify session and GraphQL client
  session = ShopifyAPI::Auth::Session.new(
    shop: 'your-development-store.myshopify.com',
    access_token: 'your_access_token_here'
  )
  client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

  # Instantiate and use the GetLocations class
  locations_query = Propel::Config::Templates::Locations::GetLocations.new(client)
  all_locations = locations_query.fetch_all

  puts "Total Locations: #{all_locations.size}"
  all_locations.each do |location|
    puts "ID: #{location['id']}, Name: #{location['name']}"
    puts "Address: #{location['address1']} #{location['address2']}, #{location['city']}, #{location['province']} #{location['zip']}, #{location['country']}"
    puts "Active: #{location['isActive']}, Fulfills Online Orders: #{location['fulfillsOnlineOrders']}"
    puts "----"
  end
=end
