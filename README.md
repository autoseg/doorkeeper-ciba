# Doorkeeper::OpenidConnect::Ciba
Doorkeeper support for OpenID Connect Client Initiated Backchannel Authentication Flow

This library, in early development status, aims to implements the [OpenID Connect Client-Initiated Backchannel Authentication Flow - Core 1.0](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) for Rails applications on top of the [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) OAuth 2.0 framework and [Doorkeeper::OpenidConnect](https://github.com/doorkeeper-gem/doorkeeper-openid_connect) extention.

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
- [Inside CIBA: BackChannel Endpoint and APIs for POLL mode, parameters in request](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.5)
- [Inside CIBA: Authentication using "urn:openid:params:grant-type:ciba" grant_type for POLL mode](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#registration)
- [Outside CIBA: Sample Web consent channel]: The CIBA specification doesn´t define how the consent channel should be implemented. The idea is to develop a sample web application, protected by Open Id/Oauth2, for the user give the consent. The application will be accessed through a link found in a e-mail notification, an email that will be sent by the backchannel endpoint flow (asking for consent).  After the user fills in their credentials and confirms/refute consent, the approval status of the pending CIBA flow will be changed to approved/disapproved. The notes found in spec follow bellow:
  - [Consent flow CIBA description](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.8)
  - [OpenID Consent Guide](https://openid.net/specs/openid-connect-core-1_0.html#Consent)

Affected endpoints:

- New endpoints:
  - POST /backchannel/authorize --> authentication requests w/ possible [parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request), returning [parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_authentication_request_acknowdlegment) auth_req_id, expires_in and interval, or [error response](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response)
  - POST /backchannel/complete --> completes the process after end-user authentication and consent confirmation, receive the authorized user (via oauth2/OID) and the auth_req_id. 

- Changed endpoints:
  - POST /oauth/token --> [token requests](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_request) w/ grant_type urn:openid:params:grant-type:ciba and auth_req_id, [returning](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_response) access_token, token_type, refresh_token, expires_in and id_token, or [error response](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_error_response)

ps. auth_req_id --> "authentication request ID" (transaction identifier) issued from the backchannel authentication endpoint.

FLOW:

<pre>
+-------------+                +-------------------------------------------------------------------------+
| Consumption |                | doorkeeper-ciba                                                         |
| Device      |                |  +---------------------+                  +---------------------------+ |
|             |                |  | Inside CIBA spec    |       (3)        | Outside CIBA spec         | |
|             |  (1) POST      |  |  +---------------+  |  Notify pending  |  +----------------------+ | |
|             | -------------------> | BackChannel   |  | consent approval |  | Authorization Device | | |
|             | <-[auth_req_id]-(2)- | Authorize     | ---[Auth Result ID]--> |- OID Auth            | | |
|             |                |  |  |               |                     |  |- Consent Approval    | | |
|             |                |  |  +---------------+  |                  |  +----------------------+ | |
|             |                |  |                     |                  |            |              | |
|             |                |  |                     |                  +------------|--------------+ |
|             |                |  |                     |                           (4) |                |
|             |                |  |                     |                        [Auth Result ID]        |
|             |                |  |                     |                               |                |
|             |                |  |                     --------------------------------V------------+   |
|             |  (5) POST      |  |  +---------------+    (6)                 +--------------------+ |   |
|             | -[auth_req_id]-----> | CIBA Token    | --[Auth Result ID]-->  | Update BackChannel | |   |
|             | <-Error or token--|  | Request/Reply | <--------------------  | Request Id Status  | |   |
|             |                |  |  +---------------+                        +--------------------+ |   |
|             |                |  +------------------------------------------------------------------+   |
+-------------+                +-------------------------------------------------------------------------+

--> BackChannel Authorize - /backchannel/authorize
--> OID Auth - /oauth/authorize 
--> Consent Aproval (or disaproval) - /backchannel/complete
--> CIBA Token Request/Reply - /oauth/token w/ grant_type = urn:openid:params:grant-type:ciba
--> Notify pending consent approval - Via e-mail to v 1.0, plugable in the future
--> 5 and 6 repeat until expires between minimum interval returned by BackChannel Authorize
--> Authorization Device will use a sample web application for v1.0

</pre>


- Features that will be planned in near future:
  - Plugable consent notification logic in backchannel authorization flow.
  - PUSH and PING mode:
    - [Notification Endpoint](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#backchannel_client_notification_endpoint)
    - Support for client_notification_token parameter in backchannel and token endpoint
  - Suport for [signed request parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#signed_auth_request)
  - Support for [user codes](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#user_code).
  - "Mutual TLS" support validation / adaptations (client_id)

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
POST  /backchannel/authorize
POST  /backchannel/complete
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
