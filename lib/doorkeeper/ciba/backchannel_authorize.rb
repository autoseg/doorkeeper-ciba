# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Authorize < CommonBusinessRules
		      def initialize(params, server)
		        @params = params
				@scope = server.client.scopes
				@client= server.client
				@application_id = server.client.id
		      end
		
			  # authorize public method
			  def authorize
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				
				# scope must include openid
				@scope = @params[:scope].to_s
				#
				# Bearer token to me used in ciba callback
				# required for ping and push mode (used to notify the callback in these modes) 
				@client_notification_token = @params[:client_notification_token].to_s
				#
				# TODO: UNSUPPORTED for v1.0 #
				# optional parameter - authentication context classes 
	 			#@acr_values = @params[:acr_values].to_s
				#
				# mutual required (user identity group)- some identification of the user (implementation specific)
				@login_hint_token = @params[:login_hint_token].to_s
				#
				# mutual required (user identity group)- id of a valid token of an user
				@id_token_hint = @params[:id_token_hint].to_s
				#
				# mutual required (user identity group) - the value may contain an email address, phone number, account number, subject identifier, username, etc.
				@login_hint = @params[:login_hint].to_s
				#
				# optional - human readable message to be displayed to the users on both consumption and authorization device
				@binding_message = @params[:binding_message].to_s
				#
				# TODO: UNSUPPORTED for v1.0 #
				# optional - secret client code known only by the user - used to prevent unsolicited authentication requests - 
				#@user_code = @params[:user_code].to_s
				#
				# optional - A positive integer allowing the client to request the expires_in value for the auth_req_id the server will return.
				@requested_expiry = Integer(@params[:requested_expiry].to_s) rescue nil;
				#
				# validate scope
				validationResult = validate_scope(@scope)
				return validationResult unless validationResult.blank?
				#
				# validate parameters
				validationResult = authorization_validate_parameters
				return validationResult unless validationResult.blank?
				#
				# validate client notification token to PING or PUSH				
				validationResult = validate_client_notification_token_parameter
				return validationResult unless validationResult.blank?
				#
				# create auth request id
				createResult = create_auth_request_id
				return createResult unless createResult.blank?
				
				# SUCCESS https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_authentication_request_acknowdlegment
		        return { 
					     json: { 
							auth_req_id: @auth_req_id,
	                        expires_in: @expires_in,
							interval: @interval
		                 }, status: 200
					   }
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def authorization_validate_parameters
	
				 ::Rails.logger.info("authorization_validate_parameters call")
			
				validationResult = validate_and_resolve_user_identity(@application_id, @login_hint, @id_token_hint, @login_hint_token)
				return validationResult unless validationResult.blank?
				
				# validate requested expiry
				if(@params[:requested_expiry].present?) 
					requested_expiry_validation = Integer(@params[:requested_expiry].to_s) rescue nil;
						
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_requested_expiry')
		                    	}, status: 400 
							} if (requested_expiry_validation.nil? || requested_expiry_validation > Doorkeeper::OpenidConnect::Ciba.configuration.max_req_id_expiration)
				end
				
				# sample bind message validation (limit the size)
				if(@params[:binding_message].present?) 
					binding_message_validation = @params[:binding_message].to_s;
						
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_binding_message')
		                    	}, status: 400 
							} if binding_message_validation.length > Doorkeeper::OpenidConnect::Ciba.configuration.max_bind_message_size
				end
				
				# client_notification_token is mandatory if the client uses PING or PUSH
				notifyTypes = Doorkeeper::OpenidConnect::Ciba::CIBA_TYPES_TO_NOTIFY_CONSUPTION_APP
				ciba_notify_type = @client.application.ciba_notify_type
				if(notifyTypes.include?(ciba_notify_type) && !@client_notification_token.present?)
  				    return { json: { 
							error: "invalid_request",
	                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_client_notification_token')
		                      }, status: 400 
						    }
				end

				return
			 end
	
			# create the auth request record
			def create_auth_request_id
				 @auth_req_id=SecureRandom.uuid 
				 @expires_in= @requested_expiry.nil? ? Doorkeeper::OpenidConnect::Ciba.configuration.default_req_id_expiration : @requested_expiry
				 @interval=Doorkeeper::OpenidConnect::Ciba.configuration.default_poll_interval

			 	 ::Rails.logger.info("## create_auth_request_id: auth_req_id => " + @auth_req_id.to_s + ", identified_user_id => " +  @identified_user_id.to_s + ", application id:" + @application_id)
			
				# Save backchannel request
				authReq = BackchannelAuthRequests.create(
											auth_req_id: @auth_req_id, 
											application_id: @application_id,
											binding_message: @binding_message, 
											scope: @scope, 
											status: BackchannelAuthRequests::STATUS_PENDING,
											client_notification_token: @client_notification_token,
											acr_values: @acr_values,
											login_hint_token: @login_hint_token,
											id_token_hint: @id_token_hint,
											login_hint: @login_hint,
				 							identified_user_id: @identified_user_id,
											user_code: @user_code,
											expires_in: @expires_in,
											interval: @interval
											)
											
					if(Doorkeeper::OpenidConnect::Ciba::CIBA_TYPES_TO_NOTIFY_CONSUPTION_APP.include?(@client.application.ciba_notify_type))
						consentNotify = ConsentNotify.new(@params, @client, authReq)
						consentNotify.notifyTheAuthorizationApplication;			
					end
				return
			end 
	   end
    end
  end
end
