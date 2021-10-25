# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class AuthorizeController < Doorkeeper::ApplicationMetalController
		#	before_action -> { doorkeeper_authorize! :openid }, only: %i[auth]

#< ActionController::API

#< Doorkeeper::ApplicationMetalController
 			#before_action :validate_presence_of_client, only: [:revoke]
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
# server.rb token_request --> request.rb token_request -> client_credentials.rb

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
			authorize_response
			
			::Rails.logger.info("#### authorize_response ===>:" + @authorize_response.status.to_s)
			
			if(authorize_response.status == :ok)
	        	render Doorkeeper::OpenidConnect::Ciba::Authorize.new(params).authorize
			else
				# show authorize response error
				render json: authorize_response.body,
	        	     status: authorize_response.status	      
			end
	    end

		private 
		
		    def authorize_response
		      @authorize_response ||= begin
		      	@strategy ||= server.token_request('client_credentials')
		
				::Rails.logger.info("#### after strategy:" + @strategy.to_s)
		
		        @auth = @strategy.authorize
		
				::Rails.logger.info("#### after authorize:" + @auth.to_s)
		
		        @auth
		      end
		    end
	  end
	end
  end
end









