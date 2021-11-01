# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class CommonBusinessRules
			# TODO : expire requests
			def check_req_expiry(request_record)
					return
			end
			
			# validate if the user was provided and search for the user identity
			def validate_and_resolve_user_identity(application_id, login_hint, id_token_hint, login_hint_token)
				# TODO: validate application_id (oauth_access_grants) ?
				
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

				# TODO: UNSUPPORTED for v.1.0				
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

			#scope must be not empty and has openid 
			def validate_scope(scope) 
				 ::Rails.logger.info("###### SCOPE:" + scope.class.to_s + " - " + scope.to_s)
			     scopes = scope.split(' ')
				
				if(!scope.present? || !scopes.include?("openid")) 
					# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_error_response
					return { json: { 
								error: "invalid_scope",
	                        	error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_scope')
	                    		}, status: 400
						    }
				end
			 return
			end



	   end
    end
  end
end