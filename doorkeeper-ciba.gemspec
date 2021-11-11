# frozen_string_literal: true

require_relative "lib/doorkeeper/ciba/version"

Gem::Specification.new do |spec|
  spec.name          = "doorkeeper-ciba"
  spec.version       = Doorkeeper::OpenidConnect::Ciba::VERSION
  spec.authors       = ["Carlos Eduardo Gorges"]
  spec.email         = ["carlos.gorges@gmail.com"]

  spec.summary       = "Doorkeeper support for OpenID Connect Client Initiated Backchannel Authentication Flow"
  spec.description   = "Doorkeeper support for OpenID Connect Client Initiated Backchannel Authentication Flow"
  spec.homepage      = "https://github.com/autoseg/doorkeeper-ciba"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "https://github.com/autoseg/doorkeeper-ciba"
  #spec.metadata["changelog_uri"] = "https://github.com/autoseg/doorkeeper-ciba/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir[
    "{app,config,lib}/**/*",
    "CHANGELOG.md",
    "LICENSE.txt",
    "README.md",
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_runtime_dependency 'doorkeeper', '>= 5.5', '< 5.6'
  spec.add_runtime_dependency 'json-jwt', '>= 1.11.0'
  spec.add_runtime_dependency 'doorkeeper-openid_connect', '>= 1.8.0'
  spec.add_runtime_dependency 'redis', '>= 3.3.1'
  spec.add_runtime_dependency 'httpclient'

  spec.add_development_dependency 'conventional-changelog', '~> 1.2'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3', '>= 1.3.6'
  spec.add_development_dependency 'httpclient'
end
