session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  query {
    product(id: "gid://shopify/Product/108828309") {
      title
      totalInventory
    }
  }
QUERY

response = client.query(query: query)
