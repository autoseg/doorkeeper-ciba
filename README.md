# Doorkeeper::OpenidConnect::Ciba
Doorkeeper support for OpenID Connect Client Initiated Backchannel Authentication Flow

This library ains to implements the [OpenID Connect Client-Initiated Backchannel Authentication Flow - Core 1.0](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) for Rails applications on top of the [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) OAuth 2.0 framework and [Doorkeeper::OpenidConnect](https://github.com/doorkeeper-gem/doorkeeper-openid_connect) extention.

## Table of Contents

- [Status](#status)
  - [Known Issues](#known-issues)
  - [Example Applications](#example-applications)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Routes](#routes)
  - [Internationalization (I18n)](#internationalization-i18n)
- [Development](#development)
- [License](#license)
- [Sponsors](#sponsors)

## Status

The following parts of [OpenID Connect Client-Initiated Backchannel Authentication Flow - Core 1.0](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html) are planned to be supported for v1.0:
- [Inside CIBA: BackChannel Endpoint and APIs for POLL mode](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.5)
- [Inside CIBA: Authentication using "urn:openid:params:grant-type:ciba" grant_type for POLL mode](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#registration)
- [Outside CIBA: Sample Web consent channel]: CIBA specification doesn't define how the consent channel must be implemented. The initial idea is create an sample channel to delivery the consent notification via e-mail, this e-mail will contains a link to a web application protected by Open Id/Oauth2, where the user must fill your credentials and confirm the consent, changing the status of the pending CIBA flow (eg. accepted/denied). The notes found in spec follow bellow:
  - [Consent flow CIBA description](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.8)
  - [OpenID Consent Guide](https://openid.net/specs/openid-connect-core-1_0.html#Consent)

PUSH and PING mode will be planned in near future.

### Known Issues

- N/A

### Example Applications

- N/A

## Installation

Make sure your application is already set up with [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper#installation) and [Doorkeeper::OpenidConnect] (https://github.com/doorkeeper-gem/doorkeeper-openid_connect#installation).

Add this line to your application's `Gemfile` and run `bundle install`:

```ruby
gem 'doorkeeper-ciba', git: https://github.com/autoseg/doorkeeper-ciba, branch: 'main'
```
ps. you can exec "bundle add doorkeeper-openid_connect --git https://github.com/autoseg/doorkeeper-ciba --branch 'main'" also.

Run the installation generator to update routes and create the initializer:

```sh
rails generate doorkeeper:openid_connect:ciba:install
```

Generate a migration for Active Record (other ORMs are currently not supported):

```sh
rails generate doorkeeper:openid_connect:ciba:migration
rake db:migrate
```
## Configuration

TODO

### Routes

The installation generator will update your `config/routes.rb` to define all required routes:

``` ruby
Rails.application.routes.draw do
  use_doorkeeper_openid_connect
  use_doorkeeper_openid_connect_ciba
  # your custom routes here
end
```

This will mount the following routes:

```
GET   /oauth/userinfo
POST  /oauth/userinfo
GET   /oauth/discovery/keys
GET   /.well-known/openid-configuration
GET   /.well-known/webfinger
```

### Internationalization (I18n)

We use Rails locale files for error messages and scope descriptions, see [config/locales/en.yml](config/locales/en.yml). You can override these by adding them to your own translations in `config/locale`.

## Development

Run `bundle install` to setup all development dependencies.

To run all specs:

```sh
bundle exec rake spec
```

To generate and run migrations in the test application:

```sh
bundle exec rake migrate
```

To run the local engine server:

```sh
bundle exec rake server
```

By default, the latest Rails version is used. To use a specific version run:

```
rails=4.2.0 bundle update
```

## License

Doorkeeper::OpenidConnect::Ciba is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Sponsors

Initial development of this project was sponsored by [TODO](TODO).
