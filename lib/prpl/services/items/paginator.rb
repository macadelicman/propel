module Prpl
  module Services
    module Items
      class Paginator
        DEFAULT_PER_PAGE = 10
        DEFAULT_PAGE = 1

        attr_reader :scope, :options

        def self.paginate(scope:, **options)
          new(scope, options).paginate
        end

        def initialize(scope, options = {})
          @scope = scope
          @options = options
          @page = [options[:page].to_i, DEFAULT_PAGE].max
          @per_page = [options[:per_page].to_i, DEFAULT_PER_PAGE].max
          validate_scope!
        end

        def paginate
          Prpl.logger.info "Paginating results", context: pagination_context

          results = paginate_scope

          Prpl::Result.success(
            data: results,
            metadata: build_metadata(results)
          )
        rescue Prpl::Errors::Error => e
          Prpl.logger.error "Pagination error: #{e.message}"
          Prpl::Result.error(e.message, status: :unprocessable_entity)
        rescue => e
          Prpl.logger.error "Unexpected error in paginator: #{e.message}"
          Prpl.logger.error e.backtrace.join("\n")
          Prpl::Result.error("Pagination failed", status: :internal_server_error)
        end

        private

          def paginate_scope
            if scope.respond_to?(:offset) && scope.respond_to?(:limit)
              paginate_active_record
            else
              paginate_enumerable
            end
          end

          def paginate_active_record
            scope.offset(offset).limit(@per_page)
          end

          def paginate_enumerable
            scope.to_a[offset, @per_page] || []
          end

          def offset
            (@page - 1) * @per_page
          end

          def total_count
            @total_count ||= begin
                               if scope.respond_to?(:count)
                                 scope.count
                               else
                                 scope.to_a.size
                               end
                             end
          end

          def total_pages
            (total_count.to_f / @per_page).ceil
          end

          def build_metadata(results)
            {
              pagination: {
                current_page: @page,
                per_page: @per_page,
                total_pages: total_pages,
                total_count: total_count,
                offset: offset,
                next_page: next_page,
                prev_page: prev_page,
                first_page: first_page?,
                last_page: last_page?
              }
            }
          end

          def next_page
            last_page? ? nil : @page + 1
          end

          def prev_page
            first_page? ? nil : @page - 1
          end

          def first_page?
            @page == 1
          end

          def last_page?
            @page >= total_pages
          end

          def validate_scope!
            unless scope
              raise Prpl::Errors::Error, "Scope must be provided"
            end
          end

          def pagination_context
            {
              page: @page,
              per_page: @per_page,
              total_count: total_count,
              scope_type: scope.class.name
            }
          end
      end
    end
  end
end
