require 'rack/token_auth/version'

module Rack
  class TokenAuth

    UnprocessableHeader = Class.new(ArgumentError)

    def initialize(app, options = {}, &block)
      @app     = app
      @options = options
      @block   = block
    end

    def call(env)
      # Try to find API key by default HTTP Header
      token, options = *token_and_options(env["HTTP_AUTHORIZATION"])

      # If user specifies extra parameter to check also apply this filter
      if @options[:check_parameter] && token.nil?
        # Initialize Rack::Request only if needed
        rack_request  = Rack::Request.new(env)
        param_value   = @options[:check_parameter] == true ? 'api_token' : @options[:check_parameter].to_s
        param_api_key = rack_request.params[param_value]
        # Set token and options
        token, options = [param_api_key, { }] if param_api_key && param_api_key.size > 0
      end

      if @block.call(token, options, env)
        @app.call(env)
      else
        unauthorized_app.call(env)
      end
    rescue UnprocessableHeader
      unprocessable_header_app.call(env)
    end

    def unauthorized_app
      @options.fetch(:unauthorized_app) { default_unauthorized_app }
    end

    def unprocessable_header_app
      @options.fetch(:unprocessable_header_app) { default_unprocessable_header_app }
    end

    def default_unprocessable_header_app
      lambda { |env| Rack::Response.new("Unprocessable Authorization header", 400) }
    end

    def default_unauthorized_app
      lambda { |env| Rack::Response.new("Unauthorized", 401) }
    end

    # Taken and adapted from Rails
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/http_authentication.rb
    def token_and_options(header)
      token = header.to_s.match(/^Token (.*)/) { |m| m[1] }
      if token
        begin
          values = Hash[token.split(',').map do |value|
            value.strip!                      # remove any spaces between commas and values
            key, value = value.split(/\=\"?/) # split key=value pairs
            value.chomp!('"')                 # chomp trailing " in value
            value.gsub!(/\\\"/, '"')          # unescape remaining quotes
            [key, value]
          end]
          [values.delete("token"), values]
        rescue => error
          raise UnprocessableHeader, error
        end
      else
        [nil,{}]
      end
    end

  end
end
