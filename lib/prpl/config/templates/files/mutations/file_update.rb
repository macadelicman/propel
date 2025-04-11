#
# Update an image
#
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation fileUpdate($input: [FileUpdateInput!]!) {
    fileUpdate(files: $input) {
      files {
        ... on MediaImage {
          id
          image {
            url
          }
        }
      }
      userErrors {
        message
      }
    }
  }
QUERY

variables = {
  "input": {
    "id": "gid://shopify/MediaImage/1072273202",
    "originalSource": "https://example.com/image.jpg"
  }
}

response = client.query(query: query, variables: variables)

# {
#   "input": {
#     "id": "gid://shopify/MediaImage/1072273202",
#     "originalSource": "https://example.com/image.jpg"
#   }
# }

############################

#
# Update a file
#
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation FileUpdate($input: [FileUpdateInput!]!) {
    fileUpdate(files: $input) {
      userErrors {
        code
        field
        message
      }
      files {
        alt
      }
    }
  }
QUERY

variables = {
  "input": {
    "id": "gid://shopify/GenericFile/1072273203",
    "alt": "new alt text"
  }
}

response = client.query(query: query, variables: variables)

# {
#   "input": {
#     "id": "gid://shopify/GenericFile/1072273203",
#     "alt": "new alt text"
#   }
# }