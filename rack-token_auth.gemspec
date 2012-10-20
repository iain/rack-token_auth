# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/token_auth/version'

Gem::Specification.new do |gem|
  gem.name          = "rack-token_auth"
  gem.version       = Rack::TokenAuth::VERSION
  gem.authors       = ["iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{Rack middleware for using the Authorization header with token authentication}
  gem.summary       = %q{Rack middleware for using the Authorization header with token authentication}
  gem.homepage      = "https://github.com/iain/rack-token_auth"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rack"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
