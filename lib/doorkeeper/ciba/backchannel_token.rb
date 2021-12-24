# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
  		# based on doorkeeper gem client_credentials_request.rb
  		#us
		# Implementation of ciba (urn:openid:params:grant-type:ciba) grant_type for oauth token
		#
		# This code is a request processor for grant_type ciba, called by tokens_controller.rb (Doorkeeper::TokensController)
		# code based on client_credentials_request.rb from doorkeeper gem
		#		
		# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#token_request
		# Output spec: https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#token_response
		# Error spec: https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#token_error_response
		#
		# INPUT SAMPLE 
		#
		#    POST /oauth/token HTTP/1.1
		#    Host: server.example.com
		#    Content-Type: application/x-www-form-urlencoded
		#
		#    grant_type=urn%3Aopenid%3Aparams%3Agrant-type%3Aciba&
		#    auth_req_id=1c266114-a1be-4252-8ad1-04986c5b9ac1&
		#    client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3A
		#    client-assertion-type%3Ajwt-bearer&
		#    client_assertion=eyJraWQiOiJsdGFjZXNidyIsImFsZyI6IkVTMjU2In0.ey
		#    Jpc3MiOiJzNkJoZFJrcXQzIiwic3ViIjoiczZCaGRSa3F0MyIsImF1ZCI6Imh0d
		#    HBzOi8vc2VydmVyLmV4YW1wbGUuY29tL3Rva2VuIiwianRpIjoiLV9wMTZqNkhj
		#    aVhvMzE3aHZaMzEyYyIsImlhdCI6MTUzNzgxOTQ5MSwiZXhwIjoxNTM3ODE5Nzg
		#    yfQ.BjaEoqZb-81gE5zz4UYwNpC3QVSeX5XhH176vg35zjkbq3Zmv_UpHB2ZugR
		#    Va344WchTQVpaSSShLbvha4yziA
		#
		#		
		# OUTPUT SAMPLE 
		#
		#    HTTP/1.1 200 OK
		#    Content-Type: application/json
		#    Cache-Control: no-store
		#
		#    {
		#     "access_token": "G5kXH2wHvUra0sHlDy1iTkDJgsgUO1bN",
		#     "token_type": "Bearer",
		#     "refresh_token": "4bwc0ESC_IAhflf-ACC_vjD_ltc11ne-8gFPfA2Kx16",
		#     "expires_in": 120,
		#     "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2NzcyNiJ9.eyJpc3MiOiJo
		#       dHRwczovL3NlcnZlci5leGFtcGxlLmNvbSIsInN1YiI6IjI0ODI4OTc2MTAwMSIs
		#       ImF1ZCI6InM2QmhkUmtxdDMiLCJlbWFpbCI6ImphbmVkb2VAZXhhbXBsZS5jb20i
		#       LCJleHAiOjE1Mzc4MTk4MDMsImlhdCI6MTUzNzgxOTUwM30.aVq83mdy72ddIFVJ
		#       LjlNBX-5JHbjmwK-Sn9Mir-blesfYMceIOw6u4GOrO_ZroDnnbJXNKWAg_dxVynv
		#       MHnk3uJc46feaRIL4zfHf6Anbf5_TbgMaVO8iczD16A5gNjSD7yenT5fslrrW-NU
		#       _vtmi0s1puoM4EmSaPXCR19vRJyWuStJiRHK5yc3BtBlQ2xwxH1iNP49rGAQe_LH
		#       fW1G74NY5DaPv-V23JXDNEIUTY-jT-NbbtNHAxnhNPyn8kcO2WOoeIwANO9BfLF1
		#       EFWtjGPPMj6kDVrikec47yK86HArGvsIIwk1uExynJIv_tgZGE0eZI7MtVb2UlCw
		#       DQrVlg"
		#    }
		# SUCCESS - https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_response
	
	    class Token < Doorkeeper::OAuth::BaseRequest
   			  attr_reader :client, :original_scopes, :response

		      alias error_response response
		
		      delegate :error, to: :issuer

		      def initialize(server, client, parameters = {})
		        @client = client
		        @server = server
		        @response = nil
				@auth_req_id = parameters[:auth_req_id];
				#@original_scopes = parameters[:scope]
				@params = parameters
		      end

		      def access_token
		        issuer.token
		      end
		
		      def issuer
				# call a copy of openid_connect rules with CIBA_GRANT_TYPE (instead client_credentials) and create the access_token
		        @issuer ||= Doorkeeper::OpenidConnect::Ciba::Issuer.new(server, 
		        		Doorkeeper::OpenidConnect::Ciba::Validator.new(server, self))
		      end
		
		      private
		      def valid?
		      	issuerValidated = issuer; 

		      	# skips ciba validations if the validator (from client_credentials) fail (error will be produced by create call bellow)
		      	if(issuerValidated.validator.valid?)
		      		cibaValidations
		      	end
		      
		        # create the token and save to db
	   	        issuerValidated.create(@client, @scopes, @params)
		      end
			
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#token_error_response
			  def cibaValidations
				::Rails.logger.info("#### INSIDE CIBA TOKEN #################:" + @params.to_s);
				#
				# validate parameters
				token_validate_parameters
				#
				# validate auth request id
				validate_auth_request_id
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def token_validate_parameters
				::Rails.logger.info("### token_validate_parameters call: auth_req_id => " + @params[:auth_req_id].to_s)

				if(!@params[:auth_req_id].present?) 
					 raise Doorkeeper::Errors::MissingRequiredParameter, 'auth_req_id'
				end
				
				return
			end
	
			# get the auth request record
			def validate_auth_request_id
				# reuse the logic found in common business
				busRules = Doorkeeper::OpenidConnect::Ciba::CommonBusinessRules.new
				busRules.param = @params
				busRules.client = @client
				
				application_id = client.id
			
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#getting_transaction_result
				# "A Client can only register a single token delivery method and the OP MUST only deliver the Authentication Result to the Client through the registered mode."
				#
				# The token request is valid: * POLL and PING mode from /oauth/token * PUSH mode in /backchannel/complete logic
				if(
						# allow from /oauth/token with POOL or PING
						!Doorkeeper::OpenidConnect::Ciba::CIBA_TYPES_ALLOW_DIRECT_CIBA_TOKEN_REQUEST.include?(@client.application.ciba_notify_type) && 
						# allow from /oauth/complete (PUSH notify logic)
				 		(@client.application.ciba_notify_type.eql?("PUSH") && @params['CONSENT_NOTITY_LOGIC'] != true)
				  )
					raise Doorkeeper::Errors::DoorkeeperError.new('invalid_ciba_request_for_grant_type')
				end

				 ::Rails.logger.info("## validate_auth_request_id: auth_req_id => " + @auth_req_id.to_s + " application_id=>" + application_id.to_s)
			
				# Search backchannel request
				current_auth_req = BackchannelAuthRequests.find_by(auth_req_id: @auth_req_id, application_id: application_id);
				
				if(! current_auth_req.present?)  
					# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
					 raise Doorkeeper::Errors::DoorkeeperError, :invalid_grant 	 
				else
					::Rails.logger.info("##validate_auth_request_id RETURNING auth_req_id:" +  @auth_req_id + " status: " + current_auth_req[:status])

					# check expires 
					validationResult = busRules.check_req_expiry(@params, @server, current_auth_req)
					::Rails.logger.info("## validate_auth_request_id: auth_req_id => " + @auth_req_id.to_s + ' status was changed to expired !') unless validationResult.blank?
					
					# VALIDATE the request id status
					status = current_auth_req[:status];
							
					next_allowed_refresh = ((!current_auth_req['last_token_get'].nil?) ? current_auth_req['last_token_get'] + Doorkeeper::OpenidConnect::Ciba.configuration.default_poll_interval : nil)
					# compare db dates with current db date to avoid timezone issues
					current_db_time = ActiveRecord::Base.connection.execute("Select CURRENT_TIMESTAMP").first['current_timestamp']

					::Rails.logger.info("## SLOW_DOWN check: validate_auth_request_id next_allowed_refresh:" + next_allowed_refresh.to_s + " current_db_time:" + current_db_time.to_s);
					# allow execution just after configured interval
					if(!next_allowed_refresh.nil? && next_allowed_refresh > current_db_time)
						raise Doorkeeper::Errors::DoorkeeperError.new('slow_down')
					else 
						# update last_token_get field
						current_auth_req.update(last_token_get: current_db_time)				
						current_auth_req.save
					end	

					# RE-VALIDATE SCOPE STORED IN BACKCHANNEL_AUTH CALL
					requestedScopes = current_auth_req.scope;
					@original_scopes = requestedScopes
					@scopes.add(requestedScopes);
					validationResult = busRules.validate_scope(@original_scopes)
					raise Doorkeeper::Errors::DoorkeeperError, :invalid_scope unless validationResult.blank?
				
					case status
						when BackchannelAuthRequests::STATUS_APPROVED
							return
						when BackchannelAuthRequests::STATUS_PENDING
							raise Doorkeeper::Errors::DoorkeeperError.new('authorization_pending')
						when BackchannelAuthRequests::STATUS_DISAPPROVED
							raise Doorkeeper::Errors::DoorkeeperError.new('access_denied')
						when BackchannelAuthRequests::STATUS_EXPIRED
							raise Doorkeeper::Errors::DoorkeeperError.new('expired_token')
						else # sanity check
							raise Doorkeeper::Errors::DoorkeeperError.new('invalid_ciba_request_status') 
					end	
				end				
				return
			end 
	   end
    end
  end
end
