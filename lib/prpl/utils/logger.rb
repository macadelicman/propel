require 'logger'

module Prpl
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = 'prpl'
      end
    end
  end
end