#
# Create a file using a staged upload URL
#
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation fileCreate($files: [FileCreateInput!]!) {
    fileCreate(files: $files) {
      files {
        id
        fileStatus
        alt
        createdAt
      }
    }
  }
QUERY

variables = {
  "files": {
    "alt": "fallback text for a video",
    "contentType": "VIDEO",
    "originalSource": "https://snowdevil.myshopify.com/admin/tmp/files"
  }
}

response = client.query(query: query, variables: variables)

# {
#   "files": {
#     "alt": "fallback text for a video",
#     "contentType": "VIDEO",
#     "originalSource": "https://snowdevil.myshopify.com/admin/tmp/files"
#   }
# }

##########################################################################

#
# Create a file using an external URL
#
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation fileCreate($files: [FileCreateInput!]!) {
    fileCreate(files: $files) {
      files {
        id
        fileStatus
        alt
        createdAt
      }
    }
  }
QUERY

variables = {
  "files": {
    "alt": "fallback text for an image",
    "contentType": "IMAGE",
    "originalSource": "https://example.com/image.jpg"
  }
}

response = client.query(query: query, variables: variables)

# {
#   "files": {
#     "alt": "fallback text for an image",
#     "contentType": "IMAGE",
#     "originalSource": "https://example.com/image.jpg"
#   }
# }

###########################################################

#
# Create an image with custom filename
#
session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation fileCreate($files: [FileCreateInput!]!) {
    fileCreate(files: $files) {
      files {
        id
        fileStatus
        alt
        createdAt
      }
    }
  }
QUERY

variables = {
  "files": {
    "alt": "fallback text for an image",
    "contentType": "IMAGE",
    "originalSource": "https://burst.shopifycdn.com/photos/pug-in-city.jpg",
    "filename": "dog.jpg"
  }
}

response = client.query(query: query, variables: variables)


# {
#   "files": {
#     "alt": "fallback text for an image",
#     "contentType": "IMAGE",
#     "originalSource": "https://burst.shopifycdn.com/photos/pug-in-city.jpg",
#     "filename": "dog.jpg"
#   }
# }

############################################################################

# mutation fileCreate($files: [FileCreateInput!]!) {
#   fileCreate(files: $files) {
#     files {
#       # File fields
#     }
#     userErrors {
#       field
#       message
#     }
#   }
# }
#
# {
#   "files": [
#     {
#       "alt": "<your-alt>",
#       "contentType": "EXTERNAL_VIDEO",
#       "duplicateResolutionMode": "APPEND_UUID",
#       "filename": "<your-filename>",
#       "originalSource": "<your-originalSource>"
#     }
#   ]
# }
#
# input FileCreateInput {
#   alt: String
#   contentType: FileContentType
#   duplicateResolutionMode: FileCreateInputDuplicateResolutionMode
#   filename: String
#   originalSource: String!
# }