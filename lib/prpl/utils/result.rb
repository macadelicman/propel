module Prpl
  class Result
    attr_reader :success, :data, :error, :metadata, :status

    def self.success(data: nil, metadata: {}, status: :ok)
      new(
        success: true,
        data: data,
        metadata: metadata,
        status: status
      )
    end

    def self.error(message, status: :unprocessable_entity)
      new(
        success: false,
        error: message,
        status: status
      )
    end

    def initialize(success:, data: nil, error: nil, metadata: {}, status: :ok)
      @success = success
      @data = data
      @error = error
      @metadata = metadata
      @status = status || :ok
    end

    def success?
      @success
    end

    def to_h
      {
        success: success,
        data: data,
        error: error,
        metadata: metadata,
        status: status
      }.compact
    end

    def to_json(*)
      to_h.to_json
    end
  end
end