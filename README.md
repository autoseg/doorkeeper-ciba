# Doorkeeper::OpenidConnect::Ciba
Doorkeeper support for OpenID Connect Client Initiated Backchannel Authentication Flow

This library implements the [OpenID Connect Client-Initiated Backchannel Authentication Flow - Core 1.0](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) for Rails applications on top of the [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) OAuth 2.0 framework and [Doorkeeper::OpenidConnect](https://github.com/doorkeeper-gem/doorkeeper-openid_connect) extention.

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
- [Inside CIBA: BackChannel Endpoint and APIs for POLL, PING and PUSH mode](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.5), [Notification Endpoint](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#backchannel_client_notification_endpoint)
- [Inside CIBA: Authentication using "urn:openid:params:grant-type:ciba" grant_type for POLL mode](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#registration)

Affected endpoints:

- New endpoints:
  - POST /backchannel/authorize --> authentication requests w/ possible [parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request), returning [parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_authentication_request_acknowdlegment) auth_req_id, expires_in and interval, or [error response](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response)
  - GET /backchannel/authinfo --> get auth info to show in authorization device (eg. binding message, auth req id status) 
  - POST /backchannel/complete --> completes the flow updating the consent status of request id. 
  - POST /backchannel/clientconfig --> change the client (application) configuration to CIBA: notification type (POLL, PING or PUSH) and set the notification endpoint for PING or PUSH. 

- Changed endpoints:
  - POST /oauth/token --> [token requests](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_request) w/ grant_type urn:openid:params:grant-type:ciba and auth_req_id, [returning](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_response) access_token, token_type, refresh_token, expires_in and id_token, or [error response](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_error_response)

- New Active Record tables:
  - backchannel_auth_requests - current status of an authorization request id
  - backchannel_auth_consent_history - history of consent (approve / disapprove).
- Changed Active Record tables:
  - oauth_applications - new columns ciba_notify_type and ciba_notify_endpoint (configuration for notify type)
  - oauth_access_tokens - new column ciba_auth_req_id (relation with ciba request id <-> oauth2/OID token/JWT).

ps. auth_req_id --> "authentication request ID" (transaction identifier) issued from the backchannel authentication endpoint.

POLL FLOW:

<pre>
+-------------+                +-------------------------------------------------------------------------+
| Consumption |                | doorkeeper-ciba                                                         |
| Device      |                |  +---------------------+                  +---------------------------+ |
|             |                |  | Inside CIBA spec    |       (3)        | Outside CIBA spec         | |
|             |  (1) POST      |  |  +---------------+  |  Notify pending  |  +----------------------+ | |
|             | -------------------> | BackChannel   |  | consent approval |  | Authorization Device | | |
|             | <-[auth_req_id]-(2)- | Authorize     | ---[Auth Result ID]--> |- OID Auth            | | |
|             |                |  |  |               |          (4)        |  |- Consent Approval    | | |
|             |                |  |  +---------------+ <-- [Get Auth Info] -- +----------------------+ | |
|             |                |  |                     ------ auth info --->                          | |
|             |                |  |                     |                  +------------|--------------+ |
|             |                |  |                     |                           (5) |                |
|             |                |  |                     |                        [Auth Result ID]        |
|             |                |  |                     |                               |                |
|             |                |  |                     --------------------------------V------------+   |
|             |  (6) POST      |  |  +---------------+    (7)                 +--------------------+ |   |
|             | -[auth_req_id]-----> | CIBA Token    | --[Auth Result ID]-->  | Update BackChannel | |   |
|             | <-Error or token--|  | Request/Reply | <--------------------  | Request Id Status  | |   |
|             |                |  |  +---------------+                        +--------------------+ |   |
|             |                |  +------------------------------------------------------------------+   |
+-------------+                +-------------------------------------------------------------------------+

--> BackChannel Authorize - /backchannel/authorize
--> OID Auth - /oauth/authorize 
--> Get Auth Info /backchannel/authinfo
--> Consent Aproval (or disaproval) - /backchannel/complete
--> CIBA Token Request/Reply - /oauth/token w/ grant_type = urn:openid:params:grant-type:ciba
--> Notify pending consent approval - Via e-mail to v 1.0, plugable in the future
--> 6 and 7 repeat until it expires or receive the consent response, limited by a minimum trial interval (parameters returned by backchannel-authorize).
--> Authorization Device will use a sample web application for v1.0

</pre>


- Features that will be planned in near future:
   - [Outside CIBA: Sample Web consent channel]: The CIBA specification doesn´t define how the consent channel should be implemented. The idea is to develop a sample web application, protected by Open Id/Oauth2, for the user give the consent. The application will be accessed through a link found in a e-mail notification, an email that will be sent by the backchannel authorization endpoint (asking for consent).  After the user fills in their credentials and confirms/refute consent, the approval status of the pending CIBA flow will be changed to approved/disapproved. The notes found in spec follow bellow:
     - [Consent flow CIBA description](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.8)
     - [OpenID Consent Guide](https://openid.net/specs/openid-connect-core-1_0.html#Consent)
   - Suport for [signed request parameters](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#signed_auth_request)
   - Support for [user codes](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#user_code).
   - "Mutual TLS" support - ref. [mtls](https://tools.ietf.org/html/draft-ietf-oauth-mtls#section-2.2),[ciba auth req](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request) and [ciba signed auth req](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#signed_auth_request) - validation / adaptations (client_id)
   - Maybe a queue for PING and PUSH notifications, with some resilience (RabbitMQ, Redis ou even in database, with retry, etc), instead synchronous remote calls inside APIs calls.

### Known Issues

- N/A

### Example Applications

- Seeds entry sample for test:

<pre>
appciba = Doorkeeper::Application.create!(
  name: 'CIBA',
  redirect_uri: 'https://localhost:3000/someapp',
  uid: 'CIBAUID',
  secret: 'CIBASECRET',
  scopes: 'openid ciba',
  ciba_notify_type: 'POLL', # PING OR PUSH
  # ASYNC NOTIFY ENDPOINT IS MANDATORY FOR PING OR PUSH
  ciba_notify_endpoint: 'https://localhost:3000/backchannel/testcibacallback'
)


puts "
  Client:        #{appciba.name}
  Client ID:     #{appciba.uid}
  Client Secret: #{appciba.secret}
  Redirect URI:  #{appciba.redirect_uri}
  Scopes:        #{appciba.scopes}
  ciba_notify_type:        #{appciba.ciba_notify_type}
  ciba_notify_endpoint:        #{appciba.ciba_notify_endpoint}"
</pre>

- Sample SOAPUI project can be found in Scripts/IDP-soapui-project.xml

## Installation

Make sure your application is already set up with [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper#installation) and [Doorkeeper::OpenidConnect](https://github.com/doorkeeper-gem/doorkeeper-openid_connect#installation).

Add this line to your application's `Gemfile` and run `bundle install`:

```ruby
gem 'doorkeeper-ciba', git: https://github.com/autoseg/doorkeeper-ciba, branch: 'main'
```
ps. you can exec "bundle add doorkeeper-ciba --git https://github.com/autoseg/doorkeeper-ciba --branch 'main'" also.

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

After the installation process, an initialization file with configurable options will be created in config/initializers/doorkeeper_openid_connect_ciba.rb, edit as recommended in the comments.

<pre>

Doorkeeper::OpenidConnect::Ciba.configure do

  # Expiration time for the req_id_token.
  # default_req_id_expiration 600

  # Max Expiration time for the req_id_token (default 1 day).
  # max_req_id_expiration 86400

  # Default minimum wait interval for token execution in poll mode
  #default_poll_interval 5

  # Max bind message size
  # option :max_bind_message_size, default: 128

  # mandatory configuration with the logic to validate the login_hint filled in both backchannel authentication and backchannel complete  
  # must return the id of the user as uuid
  #resolve_user_identity do |login_hint|
  #  user = User.find_by(email: login_hint, email_verified: true)
  #	user.id unless user.nil?
  #end

  # mandatory configuration with the logic to get the e-mail of the user based on auth req id  
  #resolve_email_by_auth_req_id do |auth_req_id|
  #  user = User.select('users.email').joins("inner join backchannel_auth_requests authreq on users.id = authreq.identified_user_id").where("authreq.auth_req_id" => auth_req_id)
  #  user.first.email if user.count > 0
  #end

  # mandatory config : add new permission to grant type ciba 
  Doorkeeper.configuration.grant_flows.append("urn:openid:params:grant-type:ciba")
  
end

</pre>

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
GET /backchannel/authinfo
POST  /backchannel/complete
POST /backchannel/clientconfig 
```


### Internationalization (I18n)

We use Rails locale files for error messages and scope descriptions, see [config/locales/en.yml](config/locales/en.yml). You can override these by adding them to your own translations in `config/locales`.

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


## Author


<a href="https://github.com/carlosgorges">Carlos Eduardo Gorges</a>


## Sponsors

Initial development of this project was sponsored by [TODO](TODO).
