module Prpl
  module Services
    module Inventory
      class Parser
        ADJUSTMENT_REGEX = /adjust inventory by (\-?\d+) for (.+)/i
        BULK_SEPARATOR = /[\n,;]/

        def self.parse(command)
          new(command).parse
        end

        def self.parse_bulk(commands)
          new(commands).parse_bulk
        end

        def initialize(input)
          @input = input.to_s.strip
        end

        def parse
          Prpl.logger.info "Parsing inventory command: #{@input}"
          match = @input.match(ADJUSTMENT_REGEX)
          unless match
            Prpl.logger.warn "Invalid command format: #{@input}"
            return Result.error("Invalid command format. Use 'adjust inventory by [quantity] for [SKU|UUID]'")
          end

          quantity = match[1].to_i
          identifier = match[2].strip

          Prpl.logger.info "Parsed command", context: { quantity: quantity, identifier: identifier }
          Result.success(data: { quantity: quantity, identifier: identifier })
        end

        def parse_bulk
          Prpl.logger.info "Parsing bulk inventory commands"
          commands = @input.split(BULK_SEPARATOR).map(&:strip).reject(&:empty?)
          Prpl.logger.info "Found #{commands.length} commands to process"

          results = commands.map do |cmd|
            parse_result = Parser.parse(cmd)
            unless parse_result.success?
              Prpl.logger.warn "Invalid command in bulk operation: #{cmd}"
              return Result.error("Invalid command format: #{cmd}. Use 'adjust inventory by [quantity] for [SKU|UUID]'")
            end
            parse_result.data
          end

          Result.success(data: results)
        end
      end
    end
  end
end
