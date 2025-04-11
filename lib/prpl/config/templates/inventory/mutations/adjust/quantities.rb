# frozen_string_literal: true

module Prpl
  module Config
    module Templates
      module Inventory
        module Mutations
          module Adjust
            class Quantities
              GRAPHQL_MUTATION = <<~GQL
                mutation inventoryAdjustQuantities($input: InventoryAdjustQuantitiesInput!) {
                  inventoryAdjustQuantities(input: $input) {
                    userErrors {
                      field
                      message
                    }
                    inventoryAdjustmentGroup {
                      createdAt
                      reason
                      referenceDocumentUri
                      changes {
                        name
                        delta
                      }
                    }
                  }
                }
              GQL

              attr_reader :client

              # Initializes the Quantities class with a GraphQL client.
              #
              # @param client [Object] a GraphQL client instance to execute queries.
              def initialize(client)
                @client = client
              end

              # Adjusts inventory quantity for a given item at a specific location.
              #
              # @param inventory_item_id [String] the ID of the inventory item.
              # @param location_id [String] the ID of the location where the adjustment occurs.
              # @param delta [Integer] the quantity change (positive or negative).
              # @param reference_document_uri [String] the reference document URI for tracking.
              #
              # @return [Hash] the response from the GraphQL API.
              def adjust_quantity(inventory_item_id:, location_id:, delta:, reference_document_uri:)
                input = {
                  reason: 'correction',
                  name: 'available',
                  referenceDocumentUri: reference_document_uri,
                  changes: [
                    {
                      delta: delta,
                      inventoryItemId: inventory_item_id,
                      locationId: location_id
                    }
                  ]
                }

                execute_mutation(input)
              end

              private

              # Executes the GraphQL mutation with the given input.
              #
              # @param input [Hash] the mutation input.
              # @return [Hash] the response from the GraphQL API.
              def execute_mutation(input)
                client.execute(
                  query: GRAPHQL_MUTATION,
                  variables: { input: input }
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
# # Instantiate the Quantities class.
# inventory_adjuster = Prpl::Config::Templates::Inventory::Adjust::Quantities.new(client)
#
# # Execute an inventory adjustment mutation.
# response = inventory_adjuster.adjust_quantity(
#   inventory_item_id: "gid://shopify/InventoryItem/30322695",
#   location_id: "gid://shopify/Location/124656943",
#   delta: -4,
#   reference_document_uri: "logistics://some.warehouse/take/2023-01/13"
# )
#
# puts response