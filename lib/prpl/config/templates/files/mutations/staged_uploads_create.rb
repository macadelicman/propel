session = ShopifyAPI::Auth::Session.new(
  shop: 'your-development-store.myshopify.com',
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(
  session: session
)

query = <<~QUERY
  mutation stagedUploadsCreate($input: [StagedUploadInput!]!) {
    stagedUploadsCreate(input: $input) {
      stagedTargets {
        url
        resourceUrl
        parameters {
          name
          value
        }
      }
    }
  }
QUERY

variables = {
  "input": [{ 'filename' => 'image1.png', 'mimeType' => 'image/png', 'httpMethod' => 'POST', 'resource' => 'IMAGE' }, { 'filename' => 'video.mp4', 'mimeType' => 'video/mp4', 'fileSize' => '1234', 'resource' => 'VIDEO' }, { 'filename' => '3d_model.glb', 'mimeType' => 'model/gltf-binary', 'resource' => 'MODEL_3D', 'fileSize' => '456' }]
}

response = client.query(query: query, variables: variables)

=begin
{
  "input": [
    {
      "filename": "image1.png",
      "mimeType": "image/png",
      "httpMethod": "POST",
      "resource": "IMAGE"
    },
    {
      "filename": "video.mp4",
      "mimeType": "video/mp4",
      "fileSize": "1234",
      "resource": "VIDEO"
    },
    {
      "filename": "3d_model.glb",
      "mimeType": "model/gltf-binary",
      "resource": "MODEL_3D",
      "fileSize": "456"
    }
  ]
}


RESPONSE: =>
{
  "stagedUploadsCreate": {
    "stagedTargets": [
      {
        "url": "https://snowdevil.myshopify.com/admin/tmp/files",
        "resourceUrl": "https://snowdevil.myshopify.com/tmp/26371970/products/a743377e-dca3-4d44-94a0-45ab3b06d592/image1.png",
        "parameters": [
          {
            "name": "filename",
            "value": "image1.png"
          },
          {
            "name": "mime_type",
            "value": "image/png"
          },
          {
            "name": "key",
            "value": "tmp/26371970/products/a743377e-dca3-4d44-94a0-45ab3b06d592/image1.png"
          }
        ]
      },
      {
        "url": "http://upload.example.com/target",
        "resourceUrl": "http://upload.example.com/target?external_video_id=25",
        "parameters": [
          {
            "name": "GoogleAccessId",
            "value": "video-development@video-production123.iam.gserviceaccount.com"
          },
          {
            "name": "key",
            "value": "dev/o/v/video.mp4"
          },
          {
            "name": "policy",
            "value": "abc123"
          },
          {
            "name": "signature",
            "value": "abc123"
          }
        ]
      },
      {
        "url": "http://upload.example.com/target/dev/o/v/3d_model.glb?external_model3d_id=25",
        "resourceUrl": "http://upload.example.com/target/dev/o/v/3d_model.glb?external_model3d_id=25",
        "parameters": [
          {
            "name": "GoogleAccessId",
            "value": "video-development@video-production123.iam.gserviceaccount.com"
          },
          {
            "name": "key",
            "value": "dev/o/v/3d_model.glb"
          },
          {
            "name": "policy",
            "value": "abc123"
          },
          {
            "name": "signature",
            "value": "abc123"
          }
        ]
      }
    ]
  }
}
=end