module Prpl
  module Services
    module Db
      class DatabaseOperationsHandler
        # Entry point for handling a natural language query.
        def self.handle_db_operation(model, query)
          llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])

          # Define a generic JSON schema for the operation.
          operation_schema = {
            type: "object",
            properties: {
              operation_type: {
                type: "string",
                enum: %w[create read update delete search],
                description: "The type of database operation to perform"
              },
              conditions: {
                type: "object",
                description: "The conditions for the operation"
              },
              attributes: {
                type: "object",
                description: "The attributes to set for create/update operations"
              }
            },
            required: ["operation_type"]
          }

          # Create a parser for structured output.
          parser = Langchain::OutputParsers::StructuredOutputParser.from_json_schema(operation_schema)
          format_instructions = parser.get_format_instructions

          # Build a prompt. We assume the model responds to valid_columns and available_scopes.
          prompt = <<~PROMPT
            You are a database operation assistant for a #{model.name} model.
            Available fields: #{model.valid_columns.join(', ')}
            Available scopes: #{model.respond_to?(:available_scopes) ? model.available_scopes.join(', ') : "None"}

            Convert the following natural language query into a structured database operation.
            Follow these rules:
            1. Ensure all field names match exactly.
            2. For search operations, use appropriate scopes when available.
            3. For update/delete operations, require specific conditions.
            4. Never allow mass updates/deletes without conditions.

            Query: #{query}

            #{format_instructions}
          PROMPT

          llm_response = llm.complete(prompt: prompt)
          parsed_response = parser.parse(llm_response.completion)

          # Execute the operation based on the parsed output.
          new(model, parsed_response).execute_operation
        rescue StandardError => e
          Prpl.logger.error("Error processing query: #{e.message}")
          raise e
        end

        attr_reader :model, :parsed_operation

        def initialize(model, parsed_operation)
          @model = model
          @parsed_operation = parsed_operation
        end

        def execute_operation
          case parsed_operation["operation_type"]
            when "create"
              handle_create(parsed_operation["attributes"])
            when "read"
              handle_read(parsed_operation["conditions"])
            when "update"
              handle_update(parsed_operation["conditions"], parsed_operation["attributes"])
            when "delete"
              handle_delete(parsed_operation["conditions"])
            when "search"
              handle_search(parsed_operation["conditions"])
            else
              Prpl.logger.warn("Unsupported operation type: #{parsed_operation['operation_type']}")
              nil
          end
        end

        private

          def handle_create(attributes)
            sanitized_attributes = sanitize_attributes(attributes)
            Prpl.logger.info("Creating #{model.name} with attributes: #{sanitized_attributes}")
            model.execute_create(sanitized_attributes)
          end

          def handle_read(conditions)
            sanitized_conditions = sanitize_conditions(conditions)
            model.execute_read(sanitized_conditions)
          end

          def handle_update(conditions, attributes)
            raise Prpl::Errors::Error, "Update requires specific conditions" if conditions.nil? || conditions.empty?

            sanitized_conditions = sanitize_conditions(conditions)
            sanitized_attributes = sanitize_attributes(attributes)
            Prpl.logger.info("Updating #{model.name} records with conditions: #{sanitized_conditions} and attributes: #{sanitized_attributes}")
            model.execute_update(sanitized_conditions, sanitized_attributes)
          end

          def handle_delete(conditions)
            raise Prpl::Errors::Error, "Delete requires specific conditions" if conditions.nil? || conditions.empty?

            sanitized_conditions = sanitize_conditions(conditions)
            Prpl.logger.info("Deleting #{model.name} records with conditions: #{sanitized_conditions}")
            model.execute_delete(sanitized_conditions)
          end

          def handle_search(conditions)
            sanitized_conditions = sanitize_conditions(conditions)
            model.execute_search(sanitized_conditions)
          end

          def sanitize_attributes(attributes)
            return {} unless attributes && attributes.is_a?(Hash)
            attributes.select { |key, _| model.valid_columns.include?(key.to_s) }
          end

          def sanitize_conditions(conditions)
            return {} unless conditions && conditions.is_a?(Hash)
            conditions.select { |key, _| model.valid_columns.include?(key.to_s) }
          end
      end
    end
  end
end
