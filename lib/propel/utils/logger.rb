require 'logger'

module Propel
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = 'propel'
      end
    end
  end
end