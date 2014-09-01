# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ari/version"

Gem::Specification.new do |spec|
  spec.name          = "asterisk-ari"
  spec.version       = ARI::VERSION
  spec.authors       = ["Tatsuo Kaniwa"]
  spec.email         = ["tatsuo@kaniwa.biz"]
  spec.summary       = %q{ Ruby client library for the Asterisk REST Interface (ARI) }
  spec.description   = %q{ Ruby client library for the Asterisk REST Interface (ARI) }
  spec.homepage      = "https://github.com/t-k/asterisk-ari-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = `git ls-files -- {spec}/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
