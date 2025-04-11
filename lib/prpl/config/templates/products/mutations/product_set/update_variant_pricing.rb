
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation updateProductVariantPricing($input: ProductSetInput!, $synchronous: Boolean!) {
    productSet(synchronous: $synchronous, input: $input) {
      product {
        id
        title
        description
        handle
        options(first: 5) {
          name
          position
          optionValues {
            name
          }
        }
        variants(first: 5) {
          nodes {
            price
            compareAtPrice
            selectedOptions {
              name
              optionValue {
                id
                name
              }
            }
          }
        }
      }
      userErrors {
        field
        message
      }
    }
  }
QUERY

variables = {
  "synchronous": true,
  "input": {
    "id": "gid://shopify/Product/1072481473",
    "title": "Bike frame",
    "descriptionHtml": "Blending durability with aerodynamics",
    "handle": "bike-frame",
    "productType": "parts",
    "tags": ["cycling", "bike", "parts"],
    "vendor": "Your cycling company",
    "status": "ACTIVE",
    "productOptions": [{"id"=>"gid://shopify/ProductOption/1064577289", "values"=>[{"id"=>"gid://shopify/ProductOptionValue/1054675047"}, {"id"=>"gid://shopify/ProductOptionValue/1054675048"}, {"id"=>"gid://shopify/ProductOptionValue/1054675049"}]}, {"id"=>"gid://shopify/ProductOption/1064577290", "values"=>[{"id"=>"gid://shopify/ProductOptionValue/1054675051"}, {"id"=>"gid://shopify/ProductOptionValue/1054675050"}, {"id"=>"gid://shopify/ProductOptionValue/1054675052"}]}],
    "variants": [{"id"=>"gid://shopify/ProductVariant/1070327057", "position"=>1, "price"=>94.99, "compareAtPrice"=>99.99, "optionValues"=>[{"id"=>"gid://shopify/ProductOptionValue/1054675047", "optionId"=>"gid://shopify/ProductOption/1064577289"}, {"id"=>"gid://shopify/ProductOptionValue/1054675050", "optionId"=>"gid://shopify/ProductOption/1064577290"}]}, {"id"=>"gid://shopify/ProductVariant/1070327058", "position"=>2, "price"=>259.99, "compareAtPrice"=>299.99, "optionValues"=>[{"id"=>"gid://shopify/ProductOptionValue/1054675048", "optionId"=>"gid://shopify/ProductOption/1064577289"}, {"id"=>"gid://shopify/ProductOptionValue/1054675051", "optionId"=>"gid://shopify/ProductOption/1064577290"}]}, {"id"=>"gid://shopify/ProductVariant/1070327059", "position"=>3, "price"=>169.99, "compareAtPrice"=>199.99, "optionValues"=>[{"id"=>"gid://shopify/ProductOptionValue/1054675049", "optionId"=>"gid://shopify/ProductOption/1064577289"}, {"id"=>"gid://shopify/ProductOptionValue/1054675052", "optionId"=>"gid://shopify/ProductOption/1064577290"}]}]
  }
}

response = client.query(query: query, variables: variables)

# {
#   "synchronous": true,
#   "input": {
#     "id": "gid://shopify/Product/1072481473",
#     "title": "Bike frame",
#     "descriptionHtml": "Blending durability with aerodynamics",
#     "handle": "bike-frame",
#     "productType": "parts",
#     "tags": [
#       "cycling",
#       "bike",
#       "parts"
#     ],
#     "vendor": "Your cycling company",
#     "status": "ACTIVE",
#     "productOptions": [
#       {
#         "id": "gid://shopify/ProductOption/1064577289",
#         "values": [
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675047"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675048"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675049"
#           }
#         ]
#       },
#       {
#         "id": "gid://shopify/ProductOption/1064577290",
#         "values": [
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675051"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675050"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675052"
#           }
#         ]
#       }
#     ],
#     "variants": [
#       {
#         "id": "gid://shopify/ProductVariant/1070327057",
#         "position": 1,
#         "price": 94.99,
#         "compareAtPrice": 99.99,
#         "optionValues": [
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675047",
#             "optionId": "gid://shopify/ProductOption/1064577289"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675050",
#             "optionId": "gid://shopify/ProductOption/1064577290"
#           }
#         ]
#       },
#       {
#         "id": "gid://shopify/ProductVariant/1070327058",
#         "position": 2,
#         "price": 259.99,
#         "compareAtPrice": 299.99,
#         "optionValues": [
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675048",
#             "optionId": "gid://shopify/ProductOption/1064577289"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675051",
#             "optionId": "gid://shopify/ProductOption/1064577290"
#           }
#         ]
#       },
#       {
#         "id": "gid://shopify/ProductVariant/1070327059",
#         "position": 3,
#         "price": 169.99,
#         "compareAtPrice": 199.99,
#         "optionValues": [
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675049",
#             "optionId": "gid://shopify/ProductOption/1064577289"
#           },
#           {
#             "id": "gid://shopify/ProductOptionValue/1054675052",
#             "optionId": "gid://shopify/ProductOption/1064577290"
#           }
#         ]
#       }
#     ]
#   }
# }