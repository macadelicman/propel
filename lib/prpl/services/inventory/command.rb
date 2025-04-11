module Prpl
  module Services
    module Inventory
      class Command
        attr_reader :command, :options

        def self.process(command, **options)
          new(command, options).process
        end

        def self.process_bulk(commands, **options)
          new(commands, options.merge(bulk: true)).process
        end

        def initialize(command, options = {})
          @command = command
          @options = options
          @bulk = options[:bulk] || false
          @variant_finder = options[:variant_finder]
        end

        def process
          Prpl.logger.info "Processing #{@bulk ? 'bulk' : 'single'} inventory command"
          validate_configuration!

          if @bulk
            process_bulk_command
          else
            process_single_command
          end
        rescue Prpl::Errors::ConfigurationError => e
          Prpl.logger.error "Configuration error: #{e.message}"
          Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Command processing failed: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Result.error("Command processing failed", status: :internal_server_error)
        end

        private

          def process_single_command
            Prpl.logger.info "Processing command: #{command}"
            parse_result = Parser.parse(command)
            return parse_result unless parse_result.success?

            adjustment_data = parse_result.data
            Adjuster.adjust_by_identifier(
              identifier: adjustment_data[:identifier],
              quantity: adjustment_data[:quantity],
              variant_finder: @variant_finder,
              **options
            )
          end

          def process_bulk_command
            Prpl.logger.info "Processing bulk commands"
            parse_result = Parser.parse_bulk(command)
            return parse_result unless parse_result.success?

            results = parse_result.data.map do |adjustment_data|
              result = Adjuster.adjust_by_identifier(
                identifier: adjustment_data[:identifier],
                quantity: adjustment_data[:quantity],
                variant_finder: @variant_finder,
                **options
              )
              log_adjustment_result(adjustment_data, result)
              result
            end

            build_bulk_result(results)
          end

          def validate_configuration!
            raise Prpl::Errors::ConfigurationError, "Variant finder must be provided" unless @variant_finder
            raise Prpl::Errors::ConfigurationError, "Command cannot be empty" if command.nil? || command.empty?
          end

          def log_adjustment_result(adjustment_data, result)
            context = {
              identifier: adjustment_data[:identifier],
              quantity: adjustment_data[:quantity],
              success: result.success?
            }
            if result.success?
              Prpl.logger.info "Adjustment succeeded", context: context
            else
              Prpl.logger.warn "Adjustment failed", context: context.merge(error: result.error)
            end
          end

          def build_bulk_result(results)
            successful = results.select(&:success?)
            failed = results.reject(&:success?)

            if failed.any?
              Prpl.logger.warn "Some adjustments failed", context: {
                total: results.size,
                successful: successful.size,
                failed: failed.size
              }
            end

            Result.success(
              data: {
                results: results,
                summary: {
                  total: results.size,
                  successful: successful.size,
                  failed: failed.size
                }
              },
              metadata: {
                timestamp: Time.now,
                bulk: true
              }
            )
          end
      end
    end
  end
end
