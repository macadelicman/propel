# Propel Gem

![Propel Gem](https://img.shields.io/gem/v/propel.svg)
![License](https://img.shields.io/github/license/yourusername/propel.svg)

Propel is a comprehensive Ruby gem designed to seamlessly integrate with Shopify's GraphQL API, facilitating advanced inventory management, product synchronization, and PDF generation. Whether you're looking to automate file operations, manage inventory levels, generate barcode/QR code PDFs, or enhance your product search capabilities, Propel offers a robust set of tools to streamline your e-commerce workflows.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Shopify API Integration](#shopify-api-integration)
    - [File Mutations](#file-mutations)
    - [Inventory Mutations](#inventory-mutations)
    - [Product Queries](#product-queries)
  - [Inventory Management](#inventory-management)
    - [Adjusting Quantities](#adjusting-quantities)
    - [Setting On-Hand Quantities](#setting-on-hand-quantities)
    - [Updating Inventory Items](#updating-inventory-items)
  - [PDF Generation](#pdf-generation)
    - [Barcode PDFs](#barcode-pdfs)
    - [QR Code PDFs](#qr-code-pdfs)
    - [Sheet PDFs](#sheet-pdfs)
  - [Search Services](#search-services)
    - [Product Search](#product-search)
    - [QR Code Search](#qr-code-search)
    - [Similarity Search](#similarity-search)
  - [Roda Plugin](#roda-plugin)
- [Example Usage](#example-usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Shopify GraphQL API Integration**: Perform advanced file operations, manage inventory, and query products directly from your Ruby applications.
- **Inventory Management**: Adjust quantities, set on-hand numbers, and update inventory items with ease.
- **PDF Generation**: Create professional barcode and QR code PDFs for inventory tracking, roll printing, or individual labels.
- **Product Synchronization**: Sync products from Shopify to your local database, ensuring consistency across platforms.
- **Advanced Search**: Implement robust product search functionalities, including similarity searches powered by OpenAI’s embeddings.
- **Roda Plugin**: Seamlessly integrate synchronization endpoints into your Roda-based web applications.
- **Comprehensive Error Handling & Logging**: Robust mechanisms to ensure smooth operations and easy debugging.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'propel'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install propel
```

## Configuration

Before using Propel, you need to configure it with your OpenAI API key and other settings. Create an initializer file (e.g., `config/initializers/propel.rb`) and add the following configuration:

```ruby
Propel.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] # Required for similarity search
  config.embeddings_model = 'text-embedding-small-003' # Default embeddings model
  config.default_search_limit = 5 # Default number of search results
  config.logger = Logger.new(STDOUT) # Customize logger if needed
end
```

Ensure that the necessary environment variables (like `OPENAI_API_KEY`) are set in your environment.

## Usage

Propel provides a variety of services and tools to interact with Shopify's API, manage inventory, generate PDFs, and perform advanced searches. Below are detailed explanations and examples for each major feature.

### Shopify API Integration

Propel offers a set of GraphQL mutations and queries to interact with Shopify's API, enabling file operations, inventory management, and product retrieval.

#### File Mutations

Manage files in your Shopify store through the following mutations:

- **Create a File**: Upload a file using a staged or external URL.
- **Delete a File**: Remove files by their IDs.
- **Update a File**: Modify file details such as `alt` text or `originalSource`.

**Example: Create an Image with a Custom Filename**

```ruby
require 'shopify_api'

session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

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

puts response
```

#### Inventory Mutations

Handle inventory adjustments, setting on-hand quantities, and updating inventory items.

##### Adjusting Quantities

Adjust the inventory quantity for a specific item at a given location:

```ruby
require 'shopify_api'

session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

mutation = Propel::Config::Templates::Inventory::Adjust::Quantities.new(client)
response = mutation.adjust_quantity(
  inventory_item_id: "gid://shopify/InventoryItem/30322695",
  location_id: "gid://shopify/Location/124656943",
  delta: -4,
  reference_document_uri: "logistics://some.warehouse/take/2023-01/13"
)

puts response
```

##### Setting On-Hand Quantities

Set the on-hand quantity for multiple inventory items:

```ruby
require 'shopify_api'

session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

mutation = Propel::Config::Templates::Inventory::Set::OnHandQuantities.new(client)
response = mutation.update_quantities(
  reason: "correction",
  reference_uri: "logistics://some.warehouse/take/2023-01-23T13:14:15Z",
  quantities: [
    {
      "inventoryItemId" => "gid://shopify/InventoryItem/30322695",
      "locationId" => "gid://shopify/Location/124656943",
      "quantity" => 42
    },
    {
      "inventoryItemId" => "gid://shopify/InventoryItem/113711323",
      "locationId" => "gid://shopify/Location/124656943",
      "quantity" => 13
    }
  ]
)

puts response
```

##### Updating Inventory Items

Update the details of an inventory item:

```ruby
require 'shopify_api'

session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

mutation = Propel::Config::Templates::Inventory::Update::Item.new(client)
response = mutation.update_item(
  id: "gid://shopify/InventoryItem/43729076",
  input: {
    cost: 145.89,
    tracked: false,
    countryCodeOfOrigin: "US",
    provinceCodeOfOrigin: "OR",
    harmonizedSystemCode: "621710",
    countryHarmonizedSystemCodes: [
      {
        harmonizedSystemCode: "6217109510",
        countryCode: "CA"
      }
    ]
  }
)

puts response
```

#### Product Queries

Retrieve product information from Shopify.

##### Get All Products

Fetch all products with their details:

```ruby
require 'shopify_api'

session = ShopifyAPI::Auth::Session.new(
  shop: "your-development-store.myshopify.com",
  access_token: access_token
)
client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

query = Propel::Config::Templates::Products::Queries::GetAllProducts.new(client)
products = query.fetch_all

puts products
```

##### Get Product by Handle

Retrieve a single product using its handle:

```ruby
require 'shopify_api'

client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

query = Propel::Config::Templates::Products::Queries::GetProductByHandle.new(client)
response = query.fetch_product("winter-hat")

puts response
```

## Inventory Management

Propel provides services to manage your inventory efficiently, ensuring accurate stock levels and streamlined operations.

### Adjusting Quantities

Adjust the inventory quantity for specific products or variants.

**Example:**

```ruby
result = Propel::Services::Inventory::Adjuster.adjust(
  variant: variant_instance,
  quantity: -2,
  additional_option: "value" # Additional options if needed
)

if result.success?
  puts "Inventory adjusted successfully: #{result.data}"
else
  puts "Error adjusting inventory: #{result.error}"
end
```

### Setting On-Hand Quantities

Set the exact quantity of items available in your inventory.

**Example:**

```ruby
result = Propel::Config::Templates::Inventory::Set::OnHandQuantities.new(client).update_quantities(
  reason: "restock",
  reference_uri: "logistics://warehouse/restock/2023-02-01",
  quantities: [
    {
      "inventoryItemId" => "gid://shopify/InventoryItem/30322695",
      "locationId" => "gid://shopify/Location/124656943",
      "quantity" => 50
    }
  ]
)

puts result
```

### Updating Inventory Items

Modify details of inventory items such as cost, origin, and tracking status.

**Example:**

```ruby
mutation = Propel::Config::Templates::Inventory::Update::Item.new(client)
response = mutation.update_item(
  id: "gid://shopify/InventoryItem/43729076",
  input: {
    cost: 150.00,
    tracked: true,
    countryCodeOfOrigin: "US",
    provinceCodeOfOrigin: "CA",
    harmonizedSystemCode: "620000",
    countryHarmonizedSystemCodes: [
      {
        harmonizedSystemCode: "6200000000",
        countryCode: "US"
      }
    ]
  }
)

puts response
```

## PDF Generation

Generate professional PDFs for inventory management, including barcode and QR code labels.

### Barcode PDFs

Create barcode PDFs for your inventory variants.

**Example:**

```ruby
barcode_pdf = Propel::Pdf::BarcodeGenerator.generate_barcode_pdf(variant_instance)
File.open('barcode_label.pdf', 'wb') { |f| f.write(barcode_pdf) }
```

### QR Code PDFs

Generate QR code PDFs for quick inventory scanning and management.

**Example:**

```ruby
qr_data = Propel::Pdf::QrCodeData.new(variant_instance, validator_instance)
qr_image = Propel::Pdf::QrCodeImage.new(qr_data.product_url)
pdf_generator = Propel::Pdf::QrCodePdfGenerator.new(qr_image, qr_data)

pdf_data = pdf_generator.generate_pdf('qr_label.pdf')
File.open('qr_label.pdf', 'wb') { |f| f.write(pdf_data) }
```

### Sheet PDFs

Create sheets containing multiple barcode or QR code labels for bulk printing.

**Example:**

```ruby
sheet_pdf = Propel::Pdf::SheetGenerator.generate_barcode_qr_sheet(variant_instance, column_gap: 0.2, row_gap: 0.2)
File.open('barcode_qr_sheet.pdf', 'wb') { |f| f.write(sheet_pdf) }
```

### Roll Labels

Generate roll labels for continuous inventory labeling.

**Example:**

```ruby
roll_label = Propel::Pdf::RollLabel.new(variant_instance)
pdf_data = roll_label.generate
File.open('roll_label.pdf', 'wb') { |f| f.write(pdf_data) }
```

## Search Services

Enhance your product search capabilities with Propel's advanced search services.

### Product Search

Perform robust searches on products based on various attributes.

**Example:**

```ruby
finder = Propel::Services::Items::Finder.new(scope: Product.all, query: "winter hat", category: "Apparel")
result = finder.find

if result.success?
  products = result.data
  puts "Found #{products.size} products:"
  products.each { |p| puts p.title }
else
  puts "Search failed: #{result.error}"
end
```

### QR Code Search

Search for products based on their QR codes.

**Example:**

```ruby
qr_search = Propel::Services::Search::Qr.new(query: "some-qr-code-data", scope: Product.all)
result = qr_search.perform

if result.success?
  product = result.data
  puts "Found product: #{product.title}"
  # Optionally, redirect to product URL
  puts "Redirect URL: #{result.metadata[:redirect_url]}"
else
  puts "QR Search failed: #{result.error}"
end
```

### Similarity Search

Find similar products using OpenAI's embeddings for enhanced search accuracy.

**Example:**

```ruby
similarity_search = Propel::Services::Search::Similarity.new(
  query: "comfortable running shoes",
  scope: Product.all
)
result = similarity_search.perform

if result.success?
  similar_products = result.data
  puts "Found #{similar_products.size} similar products:"
  similar_products.each { |p| puts p.title }
else
  puts "Similarity search failed: #{result.error}"
end
```

## Roda Plugin

Integrate Propel's synchronization endpoint into your Roda-based web applications to handle product synchronization seamlessly.

**Installation:**

Ensure Roda is included in your Gemfile:

```ruby
gem 'roda'
```

**Configuration:**

Register the `propel_item_sync` plugin in your Roda application:

```ruby
require 'propel'
require 'roda'

class App < Roda
  plugin :propel_item_sync

  route do |r|
    r.propel_item_sync_route
    # Other routes...
  end
end
```

**Usage:**

Send a POST request to the `/sync` endpoint to synchronize items.

**Example Request:**

```bash
curl -X POST http://yourapp.com/sync -H "Content-Type: application/json" -d '{
  "items": [
    { "id": "gid://shopify/Product/1", "title": "Product 1", ... },
    { "id": "gid://shopify/Product/2", "title": "Product 2", ... }
  ]
}'
```

**Handling Responses:**

- **Success:** Returns a 200 status with a success message.
- **Partial Success:** Returns a 207 status with details on successful and failed synchronizations.
- **Error:** Returns appropriate HTTP status codes with error messages.

## Example Usage

Below is a comprehensive example demonstrating how to integrate and utilize various features of the Propel gem.

1. **Setup Shopify Session:**

   ```ruby
   require 'shopify_api'
   require 'propel'

   session = ShopifyAPI::Auth::Session.new(
     shop: "your-development-store.myshopify.com",
     access_token: access_token
   )
   client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)
   ```

2. **Fetch and Sync Products:**

   ```ruby
   service = Propel::Services::Items::SyncService.new(logger: Propel.logger)
   shopify_items = service.fetch_shopify_items
   sync_result = service.sync({ "items" => shopify_items })

   if sync_result[:status] == "success"
     puts "Successfully synced #{sync_result[:details][:success_count]} items."
   else
     puts "Sync completed with errors: #{sync_result[:details][:error_count]} errors."
   end
   ```

3. **Adjust Inventory:**

   ```ruby
   result = Propel::Services::Inventory::Adjuster.adjust(
     variant: variant_instance,
     quantity: 5
   )

   if result.success?
     puts "Inventory adjusted successfully: #{result.data}"
   else
     puts "Error adjusting inventory: #{result.error}"
   end
   ```

4. **Generate a QR Code PDF:**

   ```ruby
   qr_code_data = Propel::Pdf::QrCodeData.new(variant_instance, validator)
   qr_image = Propel::Pdf::QrCodeImage.new(qr_code_data.product_url)
   pdf_generator = Propel::Pdf::QrCodePdfGenerator.new(qr_image, qr_code_data)

   pdf_data = pdf_generator.generate_pdf('qr_label.pdf')
   File.open('qr_label.pdf', 'wb') { |f| f.write(pdf_data) }
   ```

5. **Perform a Product Similarity Search:**

   ```ruby
   similarity_search = Propel::Services::Search::Similarity.new(
     query: "comfortable running shoes",
     scope: Product.all
   )
   result = similarity_search.perform

   if result.success?
     similar_products = result.data
     similar_products.each { |p| puts p.title }
   else
     puts "Similarity search failed: #{result.error}"
   end
   ```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Create a new Pull Request.

Please ensure your code follows the existing style and includes tests for new features.

## Adding Additional Queries

You can follow the same pattern to implement other queries. Here's a template you can adapt:

### Template: Generic Query Class

```ruby
require 'shopify_api'
require 'graphql'
require 'graphql/client'
require 'graphql/client/http'

module Propel
  module Config
    module Templates
      module <ModuleName>
        module Queries
          class <QueryName>
            GRAPHQL_QUERY = <<~GQL.freeze
              # Your GraphQL query here with variables
              query <QueryName>($variable1: Type!, $variable2: Type) {
                # GraphQL query structure
              }
            GQL

            attr_reader :client

            # Initializes the Query class with a GraphQL client.
            #
            # @param client [Object] A GraphQL client instance to execute queries.
            def initialize(client)
              @client = client
            end

            # Fetches data based on the query.
            #
            # @param variable1 [Type] Description
            # @param variable2 [Type, nil] Description
            # @return [Hash] The parsed JSON response from the GraphQL API.
            def fetch_data(variable1:, variable2: nil)
              variables = {
                'variable1' => variable1,
                'variable2' => variable2
              }
              response = client.query(query: GRAPHQL_QUERY, variables: variables)
              response.body.dig('data', '<root_field>')
            end
          end
        end
      end
    end
  end
end
```

### **Usage Steps**

1. **Define Your Query:**
   - Replace `<ModuleName>` with the relevant module (e.g., `Products`, `Collections`, etc.).
   - Replace `<QueryName>` with the name of your query class.
   - Write your GraphQL query in place of the placeholder.

2. **Initialize and Execute:**
   - Instantiate the query class with your GraphQL client.
   - Call the appropriate method with necessary parameters.
   - Handle the response as needed.


## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For inquiries, support, or feedback, please contact [your.email@example.com](mailto:your.email@example.com).

---

*Note: Replace placeholders like `your-development-store.myshopify.com`, `access_token`, and contact information with your actual details.*
