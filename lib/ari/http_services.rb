require "ari/json"
require "ari/response"
require "cgi"

module ARI
   module HTTPService

    def self.included(base)
      base.class_eval do
        def self.server(options = {})
          options[:host]
        end
      end# end class_eval
    end
  end

  module NetHTTPService
    require "net/http" unless defined?(Net::HTTP)
    require "net/https"

    METHODS = {
      :get    => Net::HTTP::Get,
      :post   => Net::HTTP::Post,
      :put    => Net::HTTP::Put,
      :delete => Net::HTTP::Delete
    }

    def self.included(base)
      base.class_eval do

        include ARI::HTTPService

        def self.make_request(path, args, verb, options = {})
          args.merge!({:method => verb})

          http = create_http(server(options), options)
          http.use_ssl = true if options[:port].to_i == 443

          result = http.start do |http|
            request = case verb.to_sym
              when :get
                METHODS[verb.to_sym].new "#{path}?#{encode_params(args)}"
              else
                request = METHODS[verb.to_sym].new path
                request.set_form_data args
                request
              end
            # basic auth
            if options[:username] && options[:password]
              request.basic_auth(options[:username], options[:password])
            end
            response, body = http.request(request)
            ARI::Response.new(response.code.to_i, response.body, response)
          end
        end

        protected

          def self.encode_params(param_hash)
            ((param_hash || {}).collect do |key_and_value|
              key_and_value[1] = ARI::JSON.dump(key_and_value[1]) if key_and_value[1].class != String
              "#{key_and_value[0].to_s}=#{CGI.escape key_and_value[1]}"
            end).join("&")
          end

          def self.create_http(server, options)
            if options[:proxy]
              proxy = URI.parse(options[:proxy])
              http  = Net::HTTP.new \
                server, options[:port],
                proxy.host, proxy.port,
                proxy.user, proxy.password
            else
              http = Net::HTTP.new server, options[:port]
            end
            if options[:timeout]
              http.open_timeout = options[:timeout]
              http.read_timeout = options[:timeout]
            end
            http
          end

      end
    end
  end

end