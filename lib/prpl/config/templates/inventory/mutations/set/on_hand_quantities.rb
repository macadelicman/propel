# frozen_string_literal: true

module Prpl
  module Config
    module Templates
      module Inventory
        module Mutations
          module Set
            class OnHandQuantities
              GRAPHQL_MUTATION = <<~GQL
                mutation inventorySetOnHandQuantities($input: InventorySetOnHandQuantitiesInput!) {
                  inventorySetOnHandQuantities(input: $input) {
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

              # Initializes the OnHandQuantities class with a GraphQL client.
              #
              # @param client [Object] A GraphQL client instance to execute queries.
              def initialize(client)
                @client = client
              end

              # Updates inventory quantities for multiple items.
              #
              # @param reason [String] The reason for the update.
              # @param reference_uri [String] The reference document URI.
              # @param quantities [Array<Hash>] Array of inventory quantity updates.
              #
              # @return [Hash] The response from the GraphQL API.
              def update_quantities(reason:, reference_uri:, quantities:)
                execute_mutation(build_input(reason, reference_uri, quantities))
              end

              private

              # Builds the input hash for the mutation.
              #
              # @param reason [String] The reason for the update.
              # @param reference_uri [String] The reference document URI.
              # @param quantities [Array<Hash>] The quantities to update.
              # @return [Hash] The formatted input hash.
              def build_input(reason, reference_uri, quantities)
                {
                  "input" => {
                    "reason" => reason,
                    "referenceDocumentUri" => reference_uri,
                    "setQuantities" => quantities
                  }
                }
              end

              # Executes the GraphQL mutation with the given input.
              #
              # @param variables [Hash] The mutation input variables.
              # @return [Hash] The response from the GraphQL API.
              def execute_mutation(variables)
                client.query(
                  query: GRAPHQL_MUTATION,
                  variables: variables
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
# require 'shopify_api'
#
# # Set up the Shopify session and client
# session = ShopifyAPI::Auth::Session.new(
#   shop: "your-development-store.myshopify.com",
#   access_token: access_token
# )
# client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)
#
# # Instantiate the OnHandQuantities class
# inventory_updater = Prpl::Config::Templates::Inventory::Update::OnHandQuantities.new(client)
#
# # Execute the inventory update
# response = inventory_updater.update_quantities(
#   reason: "correction",
#   reference_uri: "logistics://some.warehouse/take/2023-01-23T13:14:15Z",
#   quantities: [
#     {
#       "inventoryItemId" => "gid://shopify/InventoryItem/30322695",
#       "locationId" => "gid://shopify/Location/124656943",
#       "quantity" => 42
#     },
#     {
#       "inventoryItemId" => "gid://shopify/InventoryItem/113711323",
#       "locationId" => "gid://shopify/Location/124656943",
#       "quantity" => 13
#     }
#   ]
# )
#
# puts response