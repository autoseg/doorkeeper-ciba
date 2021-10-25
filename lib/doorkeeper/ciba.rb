# frozen_string_literal: true

require 'doorkeeper'
require 'active_model'
require 'json/jwt'

require 'doorkeeper/ciba/config'
require 'doorkeeper/ciba/engine'
require 'doorkeeper/ciba/errors'
require 'doorkeeper/ciba/version'


require 'doorkeeper/ciba/backchannel_common_business_rules'
require 'doorkeeper/ciba/backchannel_authorize'
require 'doorkeeper/ciba/backchannel_complete'

require 'doorkeeper/ciba/orm/active_record'

require 'doorkeeper/request/ciba'

require 'doorkeeper/ciba/rails/routes'

# gem main constructor
module Doorkeeper
	module OpenidConnect
	  module Ciba

# TODO: GORGES register Doorkeeper::Request::Ciba

# Doorkeeper.configuration.token_grant_flows -- ver exemplos em grant_flow.rb

	# ver request.token_strategy, está dando raise em Errors::InvalidTokenStrategy

	# register type grant_type urn:openid:params:grant-type:ciba for oauth-token
	puts("#### Doorkeeper::GrantFlow.register urn:openid:params:grant-type:ciba #################")
    Doorkeeper::GrantFlow.register(
      'ciba',
      grant_type_matches: "urn:openid:params:grant-type:ciba",
      grant_type_strategy: Doorkeeper::Request::Ciba,
    )

#   Doorkeeper::GrantFlow.register(
#      :id_token,
#      response_type_matches: 'id_token',
#      response_mode_matches: %w[fragment form_post],
#      response_type_strategy: Doorkeeper::Request::IdToken,
#    )

#    Doorkeeper::GrantFlow.register(
#      'id_token token',
#      response_type_matches: 'id_token token',
#      response_mode_matches: %w[fragment form_post],
#      response_type_strategy: Doorkeeper::Request::IdTokenToken,
#    )

    Doorkeeper::GrantFlow.register_alias(
      'ciba', as: ['ciba']
    )

	  end
	end
end
