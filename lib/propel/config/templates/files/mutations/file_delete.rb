session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation fileDelete($input: [ID!]!) {
    fileDelete(fileIds: $input) {
      deletedFileIds
    }
  }
QUERY

variables = {
  "input": ["gid://shopify/GenericFile/1072273199", "gid://shopify/MediaImage/1072273200", "gid://shopify/Video/1072273201"]
}

response = client.query(query: query, variables: variables)

# {
#   "input": [
#     "gid://shopify/GenericFile/1072273199",
#     "gid://shopify/MediaImage/1072273200",
#     "gid://shopify/Video/1072273201"
#   ]
# }