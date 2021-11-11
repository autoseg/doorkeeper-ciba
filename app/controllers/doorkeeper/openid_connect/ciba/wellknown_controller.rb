# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class WellknownController < ::ApplicationController

		# JUST TO TEST / DEBUG THE CIBA CALLBACK
	    def wellknow
			
			# TODO: develop API 
			# .well-known ENDPOINT WITH https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#registration
			#backchannel_token_delivery_modes_supported: REQUIRED. JSON array containing one or more of the following values: poll, ping, and push.
			#backchannel_authentication_endpoint: REQUIRED. URL of the OP's Backchannel Authentication Endpoint as defined in Section 7.
			#backchannel_authentication_request_signing_alg_values_supported: OPTIONAL. JSON array containing a list of the JWS signing algorithms (alg values) supported by the OP for signed authentication requests, which are described in Section 7.1.1. If omitted, signed authentication requests are not supported by the OP.
			#backchannel_user_code_parameter_supported: OPTIONAL. Boolean value specifying whether the OP supports the use of the user_code parameter, with true indicating support. If omitted, the default value is false.

			#render json: {'test': 'ok'}, status:200
	    end
	  end
	end
  end
end









