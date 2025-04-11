module Prpl
  module Config
    module Templates
      module Products
        module Serializers
          class ProductById
            # Initializes the serializer with a product hash.
            #
            # @param product [Hash] The structured product data returned from the GraphQL query.
            def initialize(product)
              @product = product
            end

            # Serializes the product data.
            #
            # @return [Hash] A hash with standardized product data.
            def serialize
              return {} unless @product

              {
                id: @product['id'],
                title: @product['title'],
                variants: serialize_variants,
                collections: serialize_collections
              }
            end

            private

            # Serializes the variants array.
            #
            # @return [Array<Hash>] An array of serialized variants.
            def serialize_variants
              return [] unless @product['variants'].is_a?(Array)
              @product['variants'].map do |variant|
                {
                  id: variant['id'],
                  title: variant['title']
                }
              end
            end

            # Serializes the collections array.
            #
            # @return [Array<Hash>] An array of serialized collections.
            def serialize_collections
              return [] unless @product['collections'].is_a?(Array)
              @product['collections'].map do |collection|
                {
                  id: collection['id'],
                  title: collection['title']
                }
              end
            end
          end
        end
      end
    end
  end
end