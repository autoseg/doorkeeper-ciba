# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class TestcibacallbackController < CommonController
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
		
	    def testcibacallback
			# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.5
			
			#client_notification_token
			#REQUIRED if the Client is registered to use Ping or Push modes. It is a bearer token provided by the Client that will 
			# be used by the OpenID Provider to authenticate the callback request to the Client. The length of the token MUST NOT 
			# exceed 1024 characters and it MUST conform to the syntax for Bearer credentials as defined in Section 2.1 of [RFC6750]. 
			# Clients MUST ensure that it contains sufficient entropy (a minimum of 128 bits while 160 bits is recommended) 
			# to make brute force guessing or forgery of a valid token computationally infeasible - the means of achieving this 
			# are implementation specific, with possible approaches including secure pseudorandom number generation or 
			#cryptographically secured self-contained tokens.

			
			::Rails.logger.info("##### testcibacallback BEGIN ###################################")
			::Rails.logger.info("##### PARAMS: " + params.to_s)
			::Rails.logger.info("##### SERVER: " + server.to_s)
			::Rails.logger.info("##### CLIENT: " + client.to_s)
			::Rails.logger.info("##### testcibacallback END #####################################")

			render json: {'test': 'ok'}, status:200
	    end
	  end
	end
  end
end









