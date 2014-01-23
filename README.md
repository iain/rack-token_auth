# Rack::TokenAuth

Rack middleware for using the Authorization header with token authentication.

Tokens are passed in the *Authorization* header, and look like this:

```
Token token="my secret token", option_a="value_a", option_b="value_b"
```

If you use Rails, you can use the [Rails built-in
methods](http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token.html)
and you don't need this gem at all.

## Usage

Add to your middleware chain, add it to `config.ru`:

``` ruby
require 'rack/token_auth'

use Rack::TokenAuth do |token, options, env|
  token == "my secret token"
end

run YourApp
```

If the block returns true, the rest of app will be invoked, if the block
returns false, the request will halt with a 401 (Unauthorized) response.

If you're using Rails, add to `config/environments/production.rb`:

``` ruby
config.middleware.use Rack::TokenAuth do |token, options, env|
  # etc...
end
```

### Optional configuration

The response in case of an unauthorized request can be modified, by specifying
a Rack app, like this:

``` ruby
unauthorized_app = lambda { |env| [ 401, {}, ["Please speak to our sales dep. for access"] ] }
use Rack::TokenAuth, :unauthorized_app => unauthorized_app do |token, options, env|
  # etc...
end
```

If the authorization header is malformed, the middleware chain will also be
halted and a 400 response will be returned. You can also specify this:

``` ruby
unprocessable_header_app = lambda { |env| [ 400, {}, ["You idiot!"] ] }
use Rack::TokenAuth, :unprocessable_header_app => unprocessable_header_app do |token, options, env|
  # etc...
end
```

You could also specify api_key in params. If you would like to handle API key
in param You need to specify :check_parameter with true or custom parameter name:

``` ruby
use Rack::TokenAuth, check_parameter: true do |token, options, env|
  # etc...
end
```

Middleware will try to find api key in headers, next it will fallback to parameter 'api_token'.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-token_auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-token_auth


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
