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
require 'doorkeeper/ciba/backchannel_getauthinfo'
require 'doorkeeper/ciba/backchannel_token'
require 'doorkeeper/ciba/backchannel_token/creator.rb'
require 'doorkeeper/ciba/backchannel_token/issuer.rb'
require 'doorkeeper/ciba/backchannel_token/validator.rb'
require 'doorkeeper/ciba/orm/active_record'
require 'doorkeeper/request/ciba'
require 'doorkeeper/ciba/rails/routes'

# overwrite
require 'doorkeeper/ciba/token_response'
require 'doorkeeper/ciba/id_token'

# gem main constructor
module Doorkeeper
	module OpenidConnect
	  module Ciba

		# workaround - declare the class dependency found in doorkeeper gem
	    #autoload :AccessGrantMixin, "doorkeeper/models/access_grant_mixin"
	    #autoload :AccessTokenMixin, "doorkeeper/models/access_token_mixin"
	    autoload :ApplicationMixin, "doorkeeper/models/application_mixin"

	    GRANT_TYPE_CIBA = "urn:openid:params:grant-type:ciba"

		# register type grant_type urn:openid:params:grant-type:ciba for oauth/token
		#puts("#### Doorkeeper::GrantFlow.register urn:openid:params:grant-type:ciba #################")
	    Doorkeeper::GrantFlow.register(
	      'urn:openid:params:grant-type:ciba',
	      grant_type_matches: "urn:openid:params:grant-type:ciba",
	      grant_type_strategy: Doorkeeper::Request::Ciba,
	    )
	  end
	end
end
