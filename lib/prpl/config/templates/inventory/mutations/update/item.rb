# frozen_string_literal: true

module Prpl
  module Config
    module Templates
      module Inventory
        module Mutations
          module Update
            class Item
              GRAPHQL_MUTATION = <<~GQL
                mutation inventoryItemUpdate($id: ID!, $input: InventoryItemInput!) {
                  inventoryItemUpdate(id: $id, input: $input) {
                    inventoryItem {
                      id
                      unitCost {
                        amount
                      }
                      tracked
                      countryCodeOfOrigin
                      provinceCodeOfOrigin
                      harmonizedSystemCode
                      countryHarmonizedSystemCodes(first: 1) {
                        edges {
                          node {
                            harmonizedSystemCode
                            countryCode
                          }
                        }
                      }
                    }
                    userErrors {
                      message
                    }
                  }
                }
              GQL

              attr_reader :client

              # Initializes the ItemUpdate class with a GraphQL client.
              #
              # @param client [Object] A GraphQL client instance to execute queries.
              def initialize(client)
                @client = client
              end

              # Updates an inventory item with the provided ID and input parameters.
              #
              # @param id [String] The ID of the inventory item.
              # @param input [Hash] A hash containing the inventory item update fields.
              #
              # @return [Hash] The response from the GraphQL API.
              def update_item(id:, input:)
                execute_mutation(id, input)
              end

              private

              # Executes the GraphQL mutation with the given id and input.
              #
              # @param id [String] The inventory item ID.
              # @param input [Hash] The mutation input.
              # @return [Hash] The response from the GraphQL API.
              def execute_mutation(id, input)
                client.execute(
                  query: GRAPHQL_MUTATION,
                  variables: { id: id, input: input }
                )
              end
            end
          end
        end
      end
    end
  end
end

# USAGE
# require 'graphql/client'
# require 'graphql/client/http'
#
# # Set up the HTTP connection to your GraphQL endpoint.
# http = GraphQL::Client::HTTP.new("https://your-graphql-endpoint.example.com/graphql")
#
# # Load the GraphQL schema.
# schema = GraphQL::Client.load_schema(http)
#
# # Create the GraphQL client.
# client = GraphQL::Client.new(schema: schema, execute: http)
#
# # Instantiate the ItemUpdate class.
# inventory_item_updater = Prpl::Config::Templates::Inventory::Update::Item.new(client)
#
# # Execute the inventory item update mutation.
# response = inventory_item_updater.update_item(
#   id: "gid://shopify/InventoryItem/43729076",
#   input: {
#     cost: 145.89,
#     tracked: false,
#     countryCodeOfOrigin: "US",
#     provinceCodeOfOrigin: "OR",
#     harmonizedSystemCode: "621710",
#     countryHarmonizedSystemCodes: [
#       {
#         harmonizedSystemCode: "6217109510",
#         countryCode: "CA"
#       }
#     ]
#   }
# )
#
# puts response