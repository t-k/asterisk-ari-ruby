module ARI
  # @!attribute [r] status
  #   @return [Integer] http status
  # @!attribute [r] body
  #   @return [String] response body
  # @!attribute [r] headers
  #   @return [String] response headers
  class Response

    def initialize(status, body, headers)
      @status  = status
      @body    = body
      @headers = headers
    end
    attr_reader :status, :body, :headers

  end
end