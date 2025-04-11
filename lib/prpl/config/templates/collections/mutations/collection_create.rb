# frozen_string_literal: true

# mutation CollectionCreate($input: CollectionInput!) {
#   collectionCreate(input: $input) {
#     userErrors {
#       field
#       message
#     }
#     collection {
#       id
#       title
#       descriptionHtml
#       handle
#       sortOrder
#       ruleSet {
#         appliedDisjunctively
#         rules {
#           column
#           relation
#           condition
#         }
#       }
#     }
#   }
# }

session = ShopifyAPI::Auth::Session.new(
  shop: 'your-development-store.myshopify.com',
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation CollectionCreate($input: CollectionInput!) {
    collectionCreate(input: $input) {
      userErrors {
        field
        message
      }
      collection {
        id
        title
        descriptionHtml
        handle
        sortOrder
        ruleSet {
          appliedDisjunctively
          rules {
            column
            relation
            condition
          }
        }
      }
    }
  }
QUERY

variables = {
  "input": {
    "title": 'Our entire shoe collection',
    "descriptionHtml": 'View <b>every</b> shoe available in our store.',
    "ruleSet": {
      "appliedDisjunctively": false,
      "rules": {
        "column": 'TITLE',
        "relation": 'CONTAINS',
        "condition": 'shoe'
      }
    }
  }
}

client.query(query: query, variables: variables)

# {
#   "input": {
#     "title": "Our entire shoe collection",
#     "descriptionHtml": "View <b>every</b> shoe available in our store.",
#     "ruleSet": {
#       "appliedDisjunctively": false,
#       "rules": {
#         "column": "TITLE",
#         "relation": "CONTAINS",
#         "condition": "shoe"
#       }
#     }
#   }
# }
