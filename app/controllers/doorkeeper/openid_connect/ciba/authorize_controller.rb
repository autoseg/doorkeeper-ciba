# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class AuthorizeController < Doorkeeper::ApplicationMetalController
		  # scope must include openid
	      #before_action -> { doorkeeper_authorize! :openid }, only: %i[auth] 
## TODO grant_flows: 'client_credentials'
# SEARC     strategy = server.token_request("client_credentials")
  # TODO: search           token_endpoint_auth_methods_supported: %w[client_secret_basic client_secret_post],

# OLHAR O tokens_controller.rb, ver como chamar direto na lógica:
#    def strategy
#      @strategy ||= server.token_request(params[:grant_type])
#    end

#    def authorize_response
#      @authorize_response ||= begin
#        before_successful_authorization
#        auth = strategy.authorize
#        context = build_context(auth: auth)
#        after_successful_authorization(context) unless auth.is_a?(Doorkeeper::OAuth::ErrorResponse)
#        auth
#      end
#    end
# Doorkeeper::Server Doorkeeper::Request
# server.rb token_request --> request.rb token_request


		# Authentication must accept the methods described in https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
		# from https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
		#
		# client_secret_basic - http header Auth Bearer w/ ""client_id : client_secret" in base64)
		# client_secret_post - request params client_id + client_secret
		# client_secret_jwt - jwt w/ client_secret signature (HMAC SHA256) / (client_assertion / client_assertion_type)- https://tools.ietf.org/html/rfc7523#section-2.2
		# private_key_jwt - jwt w/ private_key signature (HMAC SHA256) / (client_assertion / client_assertion_type)- https://tools.ietf.org/html/rfc7523#section-2.2
		# tls_client_auth - mutual tls - request params client_id and clientCertificate - https://tools.ietf.org/id/draft-ietf-oauth-mtls-03.html
		# self_signed_tls_client_auth - mutual tls - request params client_id and clientCertificate - https://datatracker.ietf.org/doc/html/rfc8705
		
	      def auth
			@strategy = server.token_request("client_credentials")

			::Rails.logger.info("after strategy" + @strategy.to_s)

        	#auth = @strategy.authorize

			#::Rails.logger.info("after auth")

			#render json: @auth

	        render json: Doorkeeper::OpenidConnect::Ciba::Authorize.new(params), status: :ok
	      end
	    end
	end
  end
end









