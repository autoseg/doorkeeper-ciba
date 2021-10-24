# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Token
		# TODO validation rules for token
		
		# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
		#https://datatracker.ietf.org/doc/html/rfc6749#section-5.2
		# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#token_error_response
		end
	end
  end
end