# app/services/sync_products_service.rb
require 'net/http'
require 'json'

class SyncProductsService
  API_URL = 'https://api.printful.com/v2/sync-products'.freeze
  LIMIT = 20
  OFFSET_START = 20
  OFFSET_END = 360

  def self.sync_products
    (OFFSET_START..OFFSET_END).step(LIMIT).each do |offset|
      response_body = fetch_products(offset)
      if response_body
        save_to_database(response_body)
      else
        Rails.logger.error("Failed to fetch products for offset: #{offset}")
      end
    end
    "Products successfully fetched and saved."
  end

  def self.fetch_products(offset)
    store_id = ENV['PRINTFUL_STORE_ID']
    url = "#{API_URL}?store_id=#{store_id}&limit=#{LIMIT}&offset=#{offset}"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{ENV['PRINTFUL_OAUTH_TOKEN']}"
    response = http.request(request)
    raise "Failed to fetch products: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  rescue StandardError => e
    Rails.logger.error("Error fetching products: #{e.message}")
    nil
  end

  def self.save_to_database(response_body)
    data = JSON.parse(response_body)
    if data['data'].present?
      data['data'].each do |product|
        product = PrintfulSyncProduct.find_or_initialize_by(printful_id: product['id'])
        product.assign_attributes(
          name: product['name'],
          external_id: product['external_id'],
          description: product['description'],
          thumbnail_url: product['thumbnail_url'],
          image_url: product['thumbnail_url'],
          is_ignored: product['is_ignored']
        )
        product.save!
      end
    else
      Rails.logger.error("No 'data' key found in the response body: #{response_body}")
    end
  rescue JSON::ParserError => e
    Rails.logger.error("JSON parsing error: #{e.message} - Response Body: #{response_body}")
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Database error: #{e.message}")
  end
end
