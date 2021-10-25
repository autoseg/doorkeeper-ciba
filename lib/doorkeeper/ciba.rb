# frozen_string_literal: true

require 'doorkeeper'
require 'active_model'
require 'json/jwt'

require 'doorkeeper/ciba/config'
require 'doorkeeper/ciba/engine'
require 'doorkeeper/ciba/errors'
require 'doorkeeper/ciba/version'

require 'doorkeeper/ciba/backchannel_authorize'
require 'doorkeeper/ciba/backchannel_complete'

require 'doorkeeper/ciba/orm/active_record'

require 'doorkeeper/ciba/rails/routes'

module Doorkeeper
	module OpenidConnect
	  module Ciba

# TODO: GORGES register Doorkeeper::Request::Ciba

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

#    Doorkeeper::GrantFlow.register_alias(
#      'implicit_oidc', as: ['implicit', 'id_token', 'id_token token']
#    )

	  end
	end
end
