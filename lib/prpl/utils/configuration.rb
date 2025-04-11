module Prpl
  class Configuration
    attr_accessor :openai_api_key, :embeddings_model, :default_search_limit, :logger
    def initialize
      @openai_api_key = nil
      @embeddings_model = 'text-embedding-small-003'
      @default_search_limit = 5
      @logger = Logger.new($stdout).tap { |l| l.progname = 'prpl' }
    end
  end
  class << self
    attr_writer :configuration
    def configuration
      @configuration ||= Configuration.new
    end
    def configure
      yield(configuration)
    end
    def logger
      configuration.logger
    end
  end
end
