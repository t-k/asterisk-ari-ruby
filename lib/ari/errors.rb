module ARI

  class ARIError < StandardError; end

  class Error < ARIError
    attr_accessor :error_info, :response_body

    def initialize(response_body = "", error_info = nil)
      if response_body &&  response_body.is_a?(String)
        @response_body = response_body.strip
      else
        @response_body = ''
      end
      if error_info.nil?
        begin
          error_info = ARI::JSON.load(response_body.to_s)
        rescue
          error_info ||= {}
        end
      end
      @error_info = error_info
      message = @response_body
      super(message)
    end
  end

  # handle 5xx response
  class ServerError < Error
    def initialize(response_body, error_info)
      @response_body = response_body
      @error_info = error_info
    end
  end

  # handle 4xx response
  class APIError < Error; end

end