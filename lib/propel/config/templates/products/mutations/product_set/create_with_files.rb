session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation createProduct($productSet: ProductSetInput!, $synchronous: Boolean!) {
    productSet(synchronous: $synchronous, input: $productSet) {
      product {
        id
        media(first: 5) {
          nodes {
            id
            position
            alt
            mediaContentType
            status
          }
        }
        variants(first: 5) {
          nodes {
            title
            price
            media(first: 5) {
              nodes {
                id
                position
                alt
                mediaContentType
                status
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
  "productSet": {
    "title": "Winter hat",
    "productOptions": [{"name"=>"Color", "position"=>1, "values"=>[{"name"=>"Grey"}, {"name"=>"Black"}]}],
    "files": [{"originalSource"=>"https://example.com/hats/grey-hat.jpg", "alt"=>"An elegant grey hat", "filename"=>"grey-hat.jpg", "contentType"=>"IMAGE"}, {"originalSource"=>"https://example.com/hats/black-hat.jpg", "alt"=>"An elegant black hat", "filename"=>"black-hat.jpg", "contentType"=>"IMAGE"}],
    "variants": [{"optionValues"=>[{"optionName"=>"Color", "name"=>"Grey"}], "file"=>{"originalSource"=>"https://example.com/hats/grey-hat.jpg", "alt"=>"An elegant grey hat", "filename"=>"grey-hat.jpg", "contentType"=>"IMAGE"}, "price"=>11.99}, {"optionValues"=>[{"optionName"=>"Color", "name"=>"Black"}], "file"=>{"originalSource"=>"https://example.com/hats/black-hat.jpg", "alt"=>"An elegant black hat", "filename"=>"black-hat.jpg", "contentType"=>"IMAGE"}, "price"=>11.99}]
  }
}

response = client.query(query: query, variables: variables)


=begin
{
  "synchronous": true,
  "productSet": {
    "title": "Winter hat",
    "productOptions": [
      {
        "name": "Color",
        "position": 1,
        "values": [
          {
            "name": "Grey"
          },
          {
            "name": "Black"
          }
        ]
      }
    ],
    "files": [
      {
        "originalSource": "https://example.com/hats/grey-hat.jpg",
        "alt": "An elegant grey hat",
        "filename": "grey-hat.jpg",
        "contentType": "IMAGE"
      },
      {
        "originalSource": "https://example.com/hats/black-hat.jpg",
        "alt": "An elegant black hat",
        "filename": "black-hat.jpg",
        "contentType": "IMAGE"
      }
    ],
    "variants": [
      {
        "optionValues": [
          {
            "optionName": "Color",
            "name": "Grey"
          }
        ],
        "file": {
          "originalSource": "https://example.com/hats/grey-hat.jpg",
          "alt": "An elegant grey hat",
          "filename": "grey-hat.jpg",
          "contentType": "IMAGE"
        },
        "price": 11.99
      },
      {
        "optionValues": [
          {
            "optionName": "Color",
            "name": "Black"
          }
        ],
        "file": {
          "originalSource": "https://example.com/hats/black-hat.jpg",
          "alt": "An elegant black hat",
          "filename": "black-hat.jpg",
          "contentType": "IMAGE"
        },
        "price": 11.99
      }
    ]
  }
}
=end