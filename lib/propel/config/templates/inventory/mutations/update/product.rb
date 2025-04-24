# frozen_string_literal: true

module Propel
  module Config
    module Templates
      module Inventory
        module Mutations
          module Update
            class Product
              GRAPHQL_MUTATION = <<~GQL
                mutation inventoryProductUpdate($id: ID!, $input: InventoryProductInput!) {
                  inventoryProductUpdate(id: $id, input: $input) {
                    inventoryProduct {
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

              # Initializes the ProductUpdate class with a GraphQL client.
              #
              # @param client [Object] A GraphQL client instance to execute queries.
              def initialize(client)
                @client = client
              end

              # Updates an inventory product with the provided ID and input parameters.
              #
              # @param id [String] The ID of the inventory product.
              # @param input [Hash] A hash containing the inventory product update fields.
              #
              # @return [Hash] The response from the GraphQL API.
              def update_product(id:, input:)
                execute_mutation(id, input)
              end

              private

              # Executes the GraphQL mutation with the given id and input.
              #
              # @param id [String] The inventory product ID.
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
# # Instantiate the ProductUpdate class.
# inventory_product_updater = Propel::Config::Templates::Inventory::Update::Product.new(client)
#
# # Execute the inventory product update mutation.
# response = inventory_product_updater.update_product(
#   id: "gid://shopify/InventoryProduct/43729076",
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