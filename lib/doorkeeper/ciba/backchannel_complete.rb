# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Complete < CommonBusinessRules
		      def initialize(params, scope)
		        @params = params
				@scope = scope
		      end
		
			  # complete public method
			  def complete
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				
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
				@login_hint_token = @params[:login_hint_token].to_s
				#
				# mutual required (user identity group)- id of the user
				@id_token_hint = @params[:id_token_hint].to_s
				#
				# mutual required (user identity group) - the value may contain an email address, phone number, account number, subject identifier, username, etc.
				@login_hint = @params[:login_hint].to_s
				#
				# UNSUPPORTED for v1.0 #
				# optional - secret client code known only by the user - used to prevent unsolicited authentication requests - 
				#@user_code = @params[:user_code].to_s
				#
				# validate scope
				validationResult = validate_scope(@scope)
				return validationResult unless validationResult.blank?
				#
				# validate parameters
				validationResult = complete_validate_parameters
				return validationResult unless validationResult.blank?
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

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def complete_validate_parameters
	
				::Rails.logger.info("complete_validate_parameters call")
	
				validationResult = validate_and_resolve_user_identity(@login_hint, @id_token_hint, @login_hint_token)
				return validationResult unless validationResult.blank?
				
				# validate if request_id is filled
				if(!@params[:auth_req_id].present?) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_req_id')
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
				# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
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
