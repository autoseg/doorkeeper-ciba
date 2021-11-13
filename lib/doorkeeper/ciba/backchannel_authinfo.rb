# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class AuthInfo < CommonBusinessRules
		      def initialize(params, server)
		        @params = params
				@scope = server.client.scopes
				@client= server.client
				@application_id = server.client.id
				@server = server
		      end
		
			  # getauthinfo public method
			  def getAuthInfo
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
				
				# auth_req_id				
				@auth_req_id = @params[:auth_req_id].to_s;
				
				# scope must include openid
				@scope = @params[:scope].to_s
				#
				# mutual required (user identity group)- some identification of the user (implementation specific)
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
				validationResult = getauthinfo_validate_parameters
				return validationResult unless validationResult.blank?
				#
				# update auth request id
				getDataResult = getauthinfo_data
				return getDataResult unless getDataResult.blank?
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def getauthinfo_validate_parameters
	
				::Rails.logger.info("complete_validate_parameters call")
	
				validationResult = validate_and_resolve_user_identity(@application_id, @login_hint, @id_token_hint, @login_hint_token)
				return validationResult unless validationResult.blank?
				
				# validate if request_id is filled
				if(!@params[:auth_req_id].present?) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_req_id')
		                    	}, status: 400 
							}
				end
				
				return
			end
	
			# get the auth request record
			def getauthinfo_data

				 ::Rails.logger.info("## getauthinfo_data: auth_req_id => " + @auth_req_id.to_s + ", identified_user_id => " +  @identified_user_id.to_s)
			
				# Search backchannel request
				current_auth_req = BackchannelAuthRequests.find_by(auth_req_id: @auth_req_id, identified_user_id: @identified_user_id, application_id: @application_id);
				
				# check if the auth_req_id is found for the user
				if(! current_auth_req.present?) 
				# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
						 return { json: { 
									error: "invalid_grant",
			                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_grant')
			                    	}, status: 400 
								}
				end
				
				# check expires 
				validationResult = check_req_expiry(@params, @server, current_auth_req)
				return validationResult unless validationResult.blank?
				
				# SUCCESS 
		        return { 
					     json: { 
							#auth_req_id: @auth_req_id,
	                        status: current_auth_req['status'],
							binding_message: current_auth_req['binding_message']
		                 }, status: 200
					   }
			end 
	   end
    end
  end
end
