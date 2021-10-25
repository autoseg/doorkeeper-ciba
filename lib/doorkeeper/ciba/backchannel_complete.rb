# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Complete < CommonBusinessRules
		      def initialize(params)
		        @params = params
		      end
		
			  # complete public method
			  def complete
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				
				# validate parameters
				validationResult = complete_validate_parameters
				return validationResult unless validationResult.blank?

				# auth_req_id				
				@auth_req_id = @params[:auth_req_id].to_s;
				
				# status (Approved or Disapproved)
				@status = @params[:status].to_s;
				
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
				#
				# UNSUPPORTED for v1.0 # mutual required (user identity group)- id of the user
				#@id_token_hint = @params[:id_token_hint].to_s
				#
				# mutual required (user identity group) - the value may contain an email address, phone number, account number, subject identifier, username, etc.
				@login_hint = @params[:login_hint].to_s
				#
				# UNSUPPORTED for v1.0 #
				# optional - secret client code known only by the user - used to prevent unsolicited authentication requests - 
				#@user_code = @params[:user_code].to_s
				#
				# update auth request id
				updateResult = update_auth_request_id_with_history
				return updateResult unless updateResult.blank?
				
				# SUCCESS 
		        return { 
					     json: { 
							auth_req_id: @auth_req_id,
	                        status: @status,
		                 }, status: 200
					   }
		      end

			  private

			  # All the error rules are descrined in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def complete_validate_parameters
	
				::Rails.logger.info("complete_validate_parameters call")
	
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
				
				# status
				@status = @params[:status].to_s;
				if(! [BackchannelAuthRequests::STATUS_APPROVED, BackchannelAuthRequests::STATUS_DISAPPROVED].include? @status)
				     return { json: { 
								error: "invalid_grant",
			                    error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_status')
			        	       	}, status: 400 
							}
				end
				
				# validate if request_id is filled
				if(!@params[:auth_req_id].present?) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_req_id')
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
				
				return
			end
	
			# update the auth request record
			def update_auth_request_id_with_history

				 ::Rails.logger.info("## update_auth_request_id_with_history: auth_req_id => " + @auth_req_id.to_s + ", identified_user_id => " +  @identified_user_id.to_s)
			
				# Search and update backchannel request, creating history
				# TODO: check expires_in 
				current_auth_req = BackchannelAuthRequests.find_by(auth_req_id: @auth_req_id, identified_user_id: @identified_user_id, status: BackchannelAuthRequests::STATUS_PENDING);
				
				# check if the auth_req_id is found for the user and in the pending status
				if(! current_auth_req.present?) 
						 return { json: { 
									error: "invalid_grant",
			                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_grant')
			                    	}, status: 400 
								}
				else
					::Rails.logger.info("## UPDATING BackchannelAuthRequests WITH auth_req_id:" +  @auth_req_id + " TO status: " + @status)
					current_auth_req.update(last_try: DateTime.now, status: @status);
					current_auth_req.save
				end
				
				# TODO: handle Error to save consent_type = E
				BackchannelAuthConsentHistory.create(
					auth_req_id: @auth_req_id, 
					login_hint_token: @login_hint_token,
					id_token_hint: @id_token_hint,
					login_hint: @login_hint,
				 	identified_user_id: @identified_user_id,
					consent_type: @status
				) 
				
				return
			end 
	   end
    end
  end
end
