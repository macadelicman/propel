require 'langchainrb'

# lib/prpl/services/search/similarity.rb
module Prpl
  module Services
    module Search
      class Similarity < Base
        DEFAULT_LIMIT = 5

        def perform
          return empty_result if query.blank?
          validate_scope!
          validate_configuration!

          Prpl.logger.info "Performing similarity search", context: search_context

          results = find_similar_products

          Prpl.logger.info "Similarity search completed", context: result_context(results)

          Prpl::Result.success(
            data: results,
            metadata: build_metadata(results)
          )
        rescue Prpl::Errors::ConfigurationError => e
          Prpl.logger.error "Configuration error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          log_error(e, search_context)
          Prpl::Result.error(
            "Similarity search failed",
            status: :internal_server_error
          )
        end

        private

          def validate_configuration!
            unless Prpl.configuration.openai_api_key
              raise Prpl::Errors::ConfigurationError, "OpenAI API key must be configured"
            end
          end

          def find_similar_products
            embeddings = initialize_embeddings
            vs = Langchain::Vectorsearch::Memory.new

            products = fetch_products
            add_products_to_vectorstore(products, vs)

            results = vs.similarity_search(query, k: search_limit)
            return_results(results, products)
          end

          def initialize_embeddings
            Langchain::LLM::OpenAI.new(
              api_key: options[:api_key] || Prpl.configuration.openai_api_key,
              embeddings_model: options[:embeddings_model] || Prpl.configuration.embeddings_model
            )
          end

          def fetch_products
            limit = search_limit
            scope.respond_to?(:limit) ? scope.limit(limit) : scope.first(limit)
          end

          def add_products_to_vectorstore(products, vs)
            products.each do |product|
              content = generate_product_content(product)
              id = product.respond_to?(:id) ? product.id.to_s : product.to_s
              vs.add_texts([content], [id])
            end
          end

          def generate_product_content(product)
            [
              :title,
              :description,
              :vendor,
              :product_category,
              :product_type,
              :variant_skus
            ].map { |attr| get_product_attribute(product, attr) }
             .compact
             .join(" ")
          end

          def get_product_attribute(product, attr)
            return unless product.respond_to?(attr)

            value = product.public_send(attr)
            if attr == :variant_skus && product.respond_to?(:variants)
              product.variants.map(&:variant_sku).join(" ")
            else
              value
            end
          end

          def return_results(results, products)
            product_ids = results.map { |r| r.metadata["id"] }

            if scope.respond_to?(:where)
              scope.where(id: product_ids)
            else
              products.select { |p| product_ids.include?(p.id.to_s) }
            end
          end

          def search_limit
            options[:limit] ||
              Prpl.configuration.default_search_limit ||
              DEFAULT_LIMIT
          end

          def search_context
            {
              query: query,
              search_type: :similarity,
              limit: search_limit,
              embeddings_model: Prpl.configuration.embeddings_model
            }
          end

          def result_context(results)
            {
              total_results: get_result_count(results),
              processing_time: calculate_processing_time
            }
          end
      end
    end
  end
end