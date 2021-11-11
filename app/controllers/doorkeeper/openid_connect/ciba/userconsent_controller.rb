# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel_client/userconsent
	    class UserconsentController < CommonController
			before_action :validate_auth_client, only: [:userconsent]
	    #
		# Authentication must accept the methods described in https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
		# from https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
		#
		# client_secret_basic - http header Auth Bearer w/ ""client_id : client_secret" in base64)
		# client_secret_post - request params client_id + client_secret
		# client_secret_jwt - jwt w/ client_secret signature (HMAC SHA256) / (client_assertion / client_assertion_type)- https://tools.ietf.org/html/rfc7523#section-2.2
		# private_key_jwt - jwt w/ private_key signature (HMAC SHA256) / (client_assertion / client_assertion_type)- https://tools.ietf.org/html/rfc7523#section-2.2
		# tls_client_auth - mutual tls - request params client_id and clientCertificate - https://tools.ietf.org/id/draft-ietf-oauth-mtls-03.html
		# self_signed_tls_client_auth - mutual tls - request params client_id and clientCertificate - https://datatracker.ietf.org/doc/html/rfc8705
		
	    def userconsent
			# TODO develop Web App
			render json: {'test': 'ok'}, status:200
	    end
	  end
	end
  end
end









