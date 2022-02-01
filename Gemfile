# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in doorkeeper-ciba.gemspec
gemspec

gem "rake", "~> 13.0"
gem 'httpclient', require: true
gem 'doorkeeper-openid_connect', require: true

#gem "rubocop", "~> 1.7"
#gem 'rubocop-performance', require: false
#gem 'rubocop-rails', require: false
#gem 'rubocop-rspec', require: false

group :development, :test do
  gem "rspec-rails", "~> 5.0"
end

group :test do
  gem "shoulda-matchers", "~> 4.5"
  gem "simplecov", "~> 0.21.2", require: false
  gem 'httparty'
end