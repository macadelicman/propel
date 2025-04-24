# frozen_string_literal: true

require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module Products
        module Queries
          class GetProduct
            GRAPHQL_QUERY = <<~GQL
              query GetProduct($id: ID!) {
                product(id: $id) {
                  id
                  title
                  variants(first: 10) {
                    nodes {
                      id
                      title
                    }
                  }
                  collections(first: 10) {
                    nodes {
                      id
                      title
                    }
                  }
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetProduct query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a single product by its Shopify numerical id.
            #
            # @param product_numeric_id [Integer, String] The numerical Shopify product id.
            # @return [Hash, nil] A hash with structured product data or nil if not found.
            def fetch(product_numeric_id)
              # Convert the numeric id into Shopify's GraphQL ID format.
              graphql_id = "gid://shopify/Product/#{product_numeric_id}"
              variables = { id: graphql_id }

              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              product_data = response.body.dig('data', 'product')
              return nil unless product_data

              # Build a structured hash with product details
              {
                'id' => product_data['id'],
                'title' => product_data['title'],
                'variants' => product_data.dig('variants', 'nodes') || [],
                'collections' => product_data.dig('collections', 'nodes') || []
              }
            end
          end
        end
      end
    end
  end
end


=begin
Below are two working usage examples that show how to integrate the new GetProduct query class into your application.

⸻

Example 1: Standalone Ruby Script

This example demonstrates how to set up a Shopify session and GraphQL client, instantiate the query class, and fetch product details by passing the Shopify numerical ID.

require 'shopify_api'
require 'json'
# require the file where the GetProduct class is defined, for example:
require_relative 'get_product'  # adjust the path as needed

# Replace these with your actual credentials and store domain
access_token = 'your_access_token_here'
shop_domain  = 'your-development-store.myshopify.com'

# Setup Shopify session and GraphQL client
session = ShopifyAPI::Auth::Session.new(shop: shop_domain, access_token: access_token)
client  = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

# Instantiate the GetProduct query class
product_query = Propel::Config::Templates::Products::Queries::GetProduct.new(client)

# Provide a Shopify numerical product id (e.g., 108828309)
product_numeric_id = 108828309

# Fetch product data
product_data = product_query.fetch(product_numeric_id)

# Output the structured product details
puts "Product Data:"
puts JSON.pretty_generate(product_data)

In this script:
	•	The numerical ID is converted to the appropriate Shopify GraphQL format.
	•	The fetch method returns a structured hash containing product details, variants, and collections.

⸻

Example 2: Integration in a Roda Application

This example shows how you might use the query class within a Roda route. The product numerical ID is provided as a query parameter.

require 'roda'
require 'json'
require 'shopify_api'
# require the file where the GetProduct class is defined, for example:
require_relative 'get_product'  # adjust the path as needed

class App < Roda
  route do |r|
    r.get "product" do
      # Expect a query parameter 'id' for the numerical Shopify product id
      product_numeric_id = r.params["id"].to_i

      # Replace these with your actual credentials and store domain
      access_token = 'your_access_token_here'
      shop_domain  = 'your-development-store.myshopify.com'

      # Setup Shopify session and GraphQL client
      session = ShopifyAPI::Auth::Session.new(shop: shop_domain, access_token: access_token)
      client  = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

      # Instantiate and use the GetProduct query class
      product_query = Propel::Config::Templates::Products::Queries::GetProduct.new(client)
      product_data = product_query.fetch(product_numeric_id)

      # Return the structured product data as JSON
      response['Content-Type'] = 'application/json'
      product_data.to_json
    end
  end
end

In this Roda example:
	•	The route /product?id=108828309 will trigger the query.
	•	The Shopify session is set up on each request (in production, consider managing sessions more efficiently).
	•	The fetched product data is returned as a JSON response.

⸻

Both examples showcase how the module is made modular and reusable, allowing you to integrate it into different parts of your application. Feel free to adjust the code to match your project’s structure and environment.


session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  query GetProduct($id: ID!) {
    product(id: $id) {
      id
      title
      variants(first: 10) {
        nodes {
          id
          title
        }
      }
      collections(first: 10) {
        nodes {
          id
          title
        }
      }
    }
  }
QUERY

variables = {
  "id": "gid://shopify/Product/108828309"
}

response = client.query(query: query, variables: variables)

---

---

---

require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module Products
        module Queries
          class GetProductById
            GRAPHQL_QUERY = <<~GQL.freeze
              query GetProductById($id: ID!) {
                product(id: $id) {
                  id
                  title
                  descriptionHtml
                  handle
                  vendor
                  productType
                  tags
                  status
                  published
                  onlineStoreUrl
                  onlineStorePreviewUrl
                  media(first: 5) {
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
                  collections(first: 10) {
                    edges {
                      node {
                        id
                        title
                        handle
                      }
                    }
                  }
                }
              }
            GQL

            attr_reader :client

            # Initializes the GetProductById query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches a product by its Shopify GraphQL ID.
            #
            # @param product_id [String] The Shopify GraphQL ID of the product.
            # @return [Hash, nil] The structured product data or nil if not found.
            def fetch_product(product_id)
              variables = { 'id' => product_id }
              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              response.body.dig('data', 'product')
            end
          end
        end
      end
    end
  end
end

#############

# USAGE EXAMPLE

require 'shopify_api'
require 'graphql/client'
require 'graphql/client/http'
require_relative 'get_product_by_id'  # Adjust the path as needed

# Setup Shopify session and GraphQL client
session = ShopifyAPI::Auth::Session.new(
  shop: 'your-development-store.myshopify.com',
  access_token: 'your_access_token_here'
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

# Instantiate and use the GetProductById class
product_id = 'gid://shopify/Product/108828309'  # Replace with your product ID
product_query = Propel::Config::Templates::Products::Queries::GetProductById.new(client)
product = product_query.fetch_product(product_id)

if product
  puts "Product Title: #{product['title']}"
  puts "Vendor: #{product['vendor']}"
  puts "Tags: #{product['tags'].join(', ')}"
else
  puts "Product with ID '#{product_id}' not found."
end
=end
