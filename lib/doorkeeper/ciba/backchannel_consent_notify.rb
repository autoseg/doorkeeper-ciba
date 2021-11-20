require 'httpclient'
require 'socket'

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class ConsentNotify < CommonBusinessRules
			
		      def initialize(params, server, authreq)
		        @params = params
				@scope = server.client.scopes
				@client= server.client
				@application_id = server.client.id
				@application = server.client.application
				@authreq = authreq
				@auth_req_id = authreq.auth_req_id;
				@server = server
		      end


			# notify the caller
			def notifyTheConsumptionApplication
				# call the rest interface configured in oauth_application - columns ciba_notify_type / ciba_notify_endpoint
				
				ciba_notify_type = @application.ciba_notify_type
				ciba_notify_endpoint = @application.ciba_notify_endpoint
				notification_token = @authreq.client_notification_token;
				
				# sanity check
				if(!Doorkeeper::OpenidConnect::Ciba::CIBA_TYPES_TO_NOTIFY_CONSUPTION_APP.include?(ciba_notify_type))
					raise StandardError, "unsupported type"					
				end
				#if(notification_token.nil? || !notification_token.present?)
				#	raise StandardError, "missing client_notification_token (Authorization Bearer)"	
				#end
				
				::Rails.logger.info("## ConsentNotify: notifyTheConsumptionApplication => reqid:" + @auth_req_id.to_s)
				::Rails.logger.info("## ConsentNotify: notifyTheConsumptionApplication => ciba_notify_type: " + ciba_notify_type.to_s + " ciba_notify_endpoint: " + ciba_notify_endpoint)
				#::Rails.logger.info("## ConsentNotify: notifyTheConsumptionApplication => client_notification_token (Bearer token): " + notification_token.to_s)
				
				if(ciba_notify_type.eql?("PING"))
				
					# PING MODE
					# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#ping_callback
					#If the Client is registered in Ping mode, the OpenID Provider will send an HTTP POST Request to the Client Notification Endpoint after a successful or failed end-user authentication.
		
					# PING MODE SAMPLE CALL			
					#    POST /cb HTTP/1.1
					#    Host: client.example.com
					#    Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
					#    Content-Type: application/json
				    #	
					#    {
					#     "auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1"
					#    }
					#
					# for PING payload the user decision (Approval or Disapproval) doesn't makes difference, even expires,
					# due the client must call CIBA Token after PING callback to get the result 
		
					message = {
								auth_req_id: @auth_req_id
							  }

				end
				if(ciba_notify_type.eql?("PUSH"))
	
					# PUSH MODE
					# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_token_push
					# if the Client is registered in Push mode and the user is well authenticated and has authorized the request, the OpenID Provider delivers a payload that includes an ID Token, 
					# an Access Token and, optionally, a Refresh Token to the Client Notification Endpoint.
					          
					#	PUSH MODE SAMPLE CALL
					#    POST /cb HTTP/1.1
					#    Host: client.example.com
					#    Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
					#    Content-Type: application/json
					#
					#    {
					#     "auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1",
					#     "access_token": "G5kXH2wHvUra0sHlDy1iTkDJgsgUO1bN",
					#     "token_type": "Bearer",
					#     "refresh_token": "4bwc0ESC_IAhflf-ACC_vjD_ltc11ne-8gFPfA2Kx16",
					#     "expires_in": 120,
					#     "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2NzcyNiJ9.eyJpc3MiOiJ
					#       odHRwczovL3NlcnZlci5leGFtcGxlLmNvbSIsInN1YiI6IjI0ODI4OTc2MTAwMS
					#       IsImF1ZCI6InM2QmhkUmtxdDMiLCJlbWFpbCI6ImphbmVkb2VAZXhhbXBsZS5jb
					#       20iLCJleHAiOjE1Mzc4MTk4MDMsImlhdCI6MTUzNzgxOTUwMywiYXRfaGFzaCI6
					#       Ild0MGtWRlhNYWNxdm5IZXlVMDAwMXciLCJ1cm46b3BlbmlkOnBhcmFtczpqd3Q
					#       6Y2xhaW06cnRfaGFzaCI6InNIYWhDdVNwWENSZzVta0REdnZyNHciLCJ1cm46b3
					#       BlbmlkOnBhcmFtczpqd3Q6Y2xhaW06YXV0aF9yZXFfaWQiOiIxYzI2NjExNC1hM
					#       WJlLTQyNTItOGFkMS0wNDk4NmM1YjlhYzEifQ.SGB5_a8E7GjwtoYrkFyqOhLK6
					#       L8-Wh1nLeREwWj30gNYOZW_ZB2mOeQ5yiXqeKJeNpDPssGUrNo-3N-CqNrbmVCb
					#       XYTwmNB7IvwE6ZPRcfxFV22oou-NS4-3rEa2ghG44Fi9D9fVURwxrRqgyezeD3H
					#       HVIFUnCxHUou3OOpj6aOgDqKI4Xl2xJ0-kKAxNR8LljUp64OHgoS-UO3qyfOwIk
					#       IAR7o4OTK_3Oy78rJNT0Y0RebAWyA81UDCSf_gWVBp-EUTI5CdZ1_odYhwB9OWD
					#       W1A22Sf6rmjhMHGbQW4A9Z822yiZZveuT_AFZ2hi7yNp8iFPZ8fgPQJ5pPpjA7u
					#       dg"
					#    }
					#
					#
					# for PUSH payload the user decision (Approval or Disapproval) makes difference, 
					# if approved - https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_token_push
					# if not aproved - https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#push_error_payload
					
						case @authreq.status
							when BackchannelAuthRequests::STATUS_APPROVED
								# get Doorkeeper::OpenidConnect::Ciba::Token (backchannel_token.rb) instance
								# code from tokens_controller.rb / create
								#
								# inform Token logic that this call is from consent notify logic - necessary to use the same logic than tokens_controller.rb
								tokenParams = @params.merge({ 'CONSENT_NOTITY_LOGIC' => true })

								# generate access_token, id_token, etc
								strategy = Doorkeeper::OpenidConnect::Ciba::Token.new(
								  Doorkeeper.config,
						          @client,
						          tokenParams,
								)
							
								auth = strategy.authorize
			
								# check if the token was generated without errors
								if(auth.status != :ok)
									raise StandardError, "Auth token error " + auth.status.to_s
								end
								
								message = { 
										auth_req_id: @auth_req_id
								   	     }
			
								message = message.merge(auth.body)
							when BackchannelAuthRequests::STATUS_DISAPPROVED
								message = notifyTheConsumptionApplication_createErrorMessage('access_denied')
							when BackchannelAuthRequests::STATUS_EXPIRED
								message = notifyTheConsumptionApplication_createErrorMessage('expired_token')
							else # sanity check
								raise Doorkeeper::Errors::DoorkeeperError.new('invalid_ciba_request_status') 
						end
				 end

				# call endpoint			
				client = HTTPClient.new
				# "Host" header is added by HTTPClient
				headers = {  "Authorization": "Bearer " + notification_token, 
							"Content-Type": "application/json" }
							
				res = client.post @application.ciba_notify_endpoint, message.to_json, headers
				result_code = res.http_header.status_code

				::Rails.logger.info("## ConsentNotify: notifyTheConsumptionApplication => reqid:" + @auth_req_id.to_s + " result_code:" + result_code.to_s)

				# test sucess
				if(result_code != 200)
					::Rails.logger.info("## ConsentNotify: notifyTheConsumptionApplication => reqid:" + @auth_req_id.to_s + " GOT ERROR STATUS FROM ENDPOINT:" + result_code.to_s + " body:" + res.body.to_s)

					raise StandardError, "notification error " + result_code.to_s
				end	 
		
			end
			
			# notify asking for consent aproval
			def notifyTheAuthorizationApplication
				# TODO does it makes sense to implement in CIBA ? 
				::Rails.logger.info("## ConsentNotify: notifyTheAuthorizationApplication ## => " + @authreq.auth_req_id.to_s + ", identified_user_id => " +  @authreq.identified_user_id.to_s + ", application id:" + @application_id)
			end
			
			private 
			
			def notifyTheConsumptionApplication_createErrorMessage(type)
					# send error message to configured endpoint
					# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#push_error_payload
				    # use the exception handler of doorkeeper gem to generate the error
					exception = Doorkeeper::Errors::DoorkeeperError.new(type)
					error = Doorkeeper::OAuth::ErrorResponse.new(name: exception.type, state: @params[:state])
					message = { 
							auth_req_id: @auth_req_id
					  	     }
					message.merge(error.body)
			end
		end
	end
  end
end