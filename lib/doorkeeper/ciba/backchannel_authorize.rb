# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Authorize
		      def initialize(params)
		        @params = params
		      end
		
			  # authorize public method
			  def authorize
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				
				# validate parameters
				validationResult = authorization_validate_parameters
				return validationResult unless validationResult.blank?
				
				# TODO: scope must include openid
				@scope = @params[:scope].to_s
				#
				# UNSUPPORTED for v1.0 #
				# required for ping and push mode (used to notify the callback in these modes) 
				#@client_notification_token = @params[:client_notification_token].to_s
				#
				# UNSUPPORTED for v1.0 #
				# optional parameter - authentication context classes 
	 			#@acr_values = @params[:acr_values].to_s
				#
				# UNSUPPORTED for v1.0 # mutual required (user identity group)- some identification of the user (implementation specific)
				#@login_hint_token = @params[:login_hint_token].to_s
				# UNSUPPORTED for v1.0 # mutual required (user identity group)- id of the user
				#@id_token_hint = @params[:id_token_hint].to_s
				# mutual required (user identity group) - the value may contain an email address, phone number, account number, subject identifier, username, etc.
				@login_hint = @params[:login_hint].to_s
				#
				# optional - human readable message to be displayed to the users on both consumption and authorization device
				@binding_message = @params[:binding_message].to_s
				#
				# UNSUPPORTED for v1.0 #
				# optional - secret client code known only by the user - used to prevent unsolicited authentication requests - 
				#@user_code = @params[:user_code].to_s
				#
				# optional - A positive integer allowing the client to request the expires_in value for the auth_req_id the server will return.
				@requested_expiry = Integer(@params[:requested_expiry].to_s) rescue nil;
				#
				# create auth request id
				create_auth_request_id
				
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

			  # All the error rules are descrined in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def authorization_validate_parameters
	
				 ::Rails.logger.info("authorization_validate_parameters call")
	
				# Parameters that identify the end-user for whom auth is being requested. At least one must be defined.
				#	
				# As in the CIBA flow the OP does not have an interaction with the end-user through the consumption device, 
				# it is REQUIRED that the Client provides one (and only one) of the hints specified above in the authentication
				# request, that is "login_hint_token", "id_token_hint" or "login_hint".
				#
				# for v.1.0 just login_hint is supported
				# future implementation: if(!(@params[:login_hint_token].present? || @params[:id_token_hint].present? || @params[:login_hint].present?)) 
				if(!(@params[:login_hint].present?)) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_user_identification')
		                    	}, status: 400 
							}
				end
				
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request_validation
				# The OpenID Provider MUST process the hint provided to determine if the hint is valid and if it corresponds to a valid user. 
				# The type, issuer (where applicable) and maximum age (where applicable) of a hint that an OP accepts should be communicated to Clients. 
				# How the OP validates hints and informs Clients of its hint requirements is out-of-scope of this specification.
				# check the end-user hint identity
				resolve_user_identity(@params[:login_hint].to_s)
				if(!@identified_user_id.present?)
					 	# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response
						return { json: { 
									error: "unknown_user_id",
		                        	error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.unknown_user_id')
		                    		}, status: 400
							    }
				end
				
				# validate requested expiry
				if(@params[:requested_expiry].present?) 
					requested_expiry_validation = Integer(@params[:requested_expiry].to_s) rescue nil;
						
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_requested_expiry')
		                    	}, status: 400 
							} if requested_expiry_validation.nil?
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
			 end
	
			# create the auth request record
			def create_auth_request_id
				 @auth_req_id=SecureRandom.uuid 
				 @expires_in= @requested_expiry.nil? ? Doorkeeper::OpenidConnect::Ciba.configuration.default_req_id_expiration : @requested_expiry
				 @interval=Doorkeeper::OpenidConnect::Ciba.configuration.default_poll_interval

				 ::Rails.logger.info("create_auth_request_id: auth_req_id ===> " + @auth_req_id.to_s)
			
				# Save backchannel request
				#     t.uuid :auth_req_id, null: false
				#     t.string :status, null: false, default: 'P'
				#     t.string :binding_message, null: true
				#     t.string :scope, null: false
				#	  t.string :client_notification_token, null: true
				#	  t.string :acr_values, null: true
				#	  t.string :login_hint_token, null: true
				#     t.string :id_token_hint, null: true
				#     t.string :login_hint, null: true
				#     t.uuid :identified_user_id, null: false
				#     t.string :user_code, null: true
				#     t.integer :expires_in, null: false
				#	  t.integer :interval, null: false
				#	  t.timestamp :last_try, null: false
				#
				#     t.timestamps             null: false
				BackchannelAuthRequests.create(
											auth_req_id: @auth_req_id, 
											binding_message: @binding_message, 
											scope: @scope, 
											client_notification_token: @client_notification_token,
											acr_values: @acr_values,
											login_hint_token: @login_hint_token,
											id_token_hint: @id_token_hint,
											login_hint: @login_hint,
				 							identified_user_id: @identified_user_id,
											user_code: @user_code,
											expires_in: @expires_in,
											interval: @interval,
											last_try: DateTime.now
											)
			end 
			
			# find the id of end-user based in login_hint parameter as e-mail
   		    def resolve_user_identity(login_hint)

   				@identified_user_id ||= Doorkeeper::OpenidConnect::Ciba.configuration.resolve_user_identity.call(login_hint)
	
				#::Rails.logger.info("resolve_user_identity => " + @identified_user_id.to_s)
      		end
			
	   end
    end
  end
end
