# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba

	    class CommonBusinessRules
			attr_writer :param

			# check if the registry was expired, change the status and return json
			def check_req_expiry(params, server, current_auth_req)
				status = current_auth_req[:status]
				expired = false
				
				# just expire in pending status
				if(status == BackchannelAuthRequests::STATUS_PENDING)
					::Rails.logger.info("CommonBusinessRules: check_req_expiry: " + current_auth_req.auth_req_id.to_s + 
							" created:"+ current_auth_req.created_at.to_s + " expired_in:" + current_auth_req.expires_in.to_s)
					expired = false
					expire_date = current_auth_req.created_at + current_auth_req.expires_in
					# compare db dates with current db date to avoid timezone issues
					current_db_time = ActiveRecord::Base.connection.execute("Select CURRENT_TIMESTAMP").first['current_timestamp']
					if(expire_date < current_db_time)
						BackchannelAuthRequests.transaction do
							# expire registry
							::Rails.logger.info("CommonBusinessRules: SET TO EXPIRED: check_req_expiry: " + current_auth_req.auth_req_id.to_s)
							current_auth_req.update(status: BackchannelAuthRequests::STATUS_EXPIRED)
							current_auth_req.save
							# TODO: create backchannel_auth_consent_history							
							expired = true
							#							
							# NOTIFY EXPIRATION IN PUSH
							# 
							if(Doorkeeper::OpenidConnect::Ciba::CIBA_TYPES_TO_NOTIFY_CONSUPTION_APP.include?(@client.application.ciba_notify_type))
								consentNotify = ConsentNotify.new(@params, @server, current_auth_req)
								consentNotify.notifyTheConsumptionApplication						
							end
							
						end
					end
				else
					if(status == BackchannelAuthRequests::STATUS_EXPIRED) 
						::Rails.logger.info("CommonBusinessRules: ALREADY EXPIRED: check_req_expiry: " + current_auth_req.auth_req_id.to_s)
						expired = true
					end
				end

				# response for synchronous calls
				if(expired)				
					return { json: { 
									error: "expired_token",
			                        error_description: I18n.translate('doorkeeper.errors.messages.expired_token')
			                    	}, status: 400 
								}
				else
					return
				end
			end
			
			# validate if the user was provided and search for the user identity
			def validate_and_resolve_user_identity(application_id, login_hint, id_token_hint, login_hint_token)
				::Rails.logger.info("validate_and_resolve_user_identity: " + application_id + "," + login_hint + "," + id_token_hint + "," + login_hint_token)
				
				#
				# Parameters that identify the end-user for whom auth is being requested. At least one must be defined.
				#	
				# As in the CIBA flow the OP does not have an interaction with the end-user through the consumption device, 
				# it is REQUIRED that the Client provides one (and only one) of the hints specified above in the authentication
				# request, that is "login_hint_token", "id_token_hint" or "login_hint".
				#
				# for v.1.0 just login_hint is supported
				#
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request_validation
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				#
				# The OpenID Provider MUST process the hint provided to determine if the hint is valid and if it corresponds to a valid user. 
				# The type, issuer (where applicable) and maximum age (where applicable) of a hint that an OP accepts should be communicated to Clients. 
				# How the OP validates hints and informs Clients of its hint requirements is out-of-scope of this specification.
				# check the end-user hint identity
				#				
				# validate if some user ident option was filled
				if(!(@params[:login_hint].present? || @params[:id_token_hint].present? || @params[:login_hint_token].present? )) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_user_identification')
		                    	}, status: 400 
							}
				end
				
				# validate if more than one was filled
				arr = [ @params[:login_hint], @params[:id_token_hint], @params[:login_hint_token] ]
				
				if(arr.count(nil) < arr.length-1) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.more_than_one_user_identification')
		                    	}, status: 400 
							}
				end

				# TODO: FUTURE FEATURE (remove the following check after develop the support for id_token_hint or login_hint_token)
				if(id_token_hint.present? || login_hint_token.present?)
					    # https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response
						return { json: { 
									error: "invalid_request",
		                        	error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.just_login_hint_is_supported')
		                    		}, status: 400
							    }
				end
				
				# some user-specific data, eg. e-mail address
				resolve_user_identity_by_login_hint(@params[:login_hint].to_s) if(@params[:login_hint].present?)
				
				# validate if the user was found
				if(!@identified_user_id.present?)
					 	# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response
						return { json: { 
									error: "unknown_user_id",
		                        	error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.unknown_user_id')
		                    		}, status: 400
							    }
				end
				return
			end


			# find the id of end-user based in login_hint parameter as e-mail
   		    def resolve_user_identity_by_login_hint(login_hint)

   				@identified_user_id ||= Doorkeeper::OpenidConnect::Ciba.configuration.resolve_user_identity.call(login_hint)
	
      		end

			#scope must be not empty and contains openid and ciba
			def validate_scope(scope) 
				 ::Rails.logger.info("###### SCOPE:" + scope.class.to_s + " - " + scope.to_s)
			     scopes = scope.split(' ')
				
				if(!scope.present? || !scopes.include?("openid") || !scopes.include?("ciba")) 
					# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response
					return { json: { 
								error: "invalid_scope",
	                        	error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_scope')
	                    		}, status: 400
						    }
				end
			 return
			end

			def validate_client_notification_token_parameter
			
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
				# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.5
				# The length of the token MUST NOT exceed 1024 characters and it MUST conform to the syntax for Bearer 
				# credentials as defined in Section 2.1 of [RFC6750]. 
				#
				# VALIDATE client_notification_token format even NOT configured as PING OR PUSH Due 
				# the possibility of admin change the type of notification after the creation of auth req ids
				if(@client_notification_token.present? && @client_notification_token.length > 1024)	
					return { json: { 
							   error: "invalid_request",
	                           error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_client_notification_token')
	                    	  }, status: 400 
							}
				end
			
			end


	   end
    end
  end
end