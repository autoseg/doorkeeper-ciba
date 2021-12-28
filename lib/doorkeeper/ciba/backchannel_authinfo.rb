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
				# used to applications to aprove pooling, list just Pending auth req id
				@poolingMode = @params[:poolingMode].to_s
				#
				# validate parameters
				validationResult = getauthinfo_validate_parameters
				return validationResult unless validationResult.blank?
				#
				# get request id data 
				getDataResult = getauthinfo_data
				return getDataResult unless getDataResult.blank?
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def getauthinfo_validate_parameters
	
				::Rails.logger.info("complete_validate_parameters call")
	
				validationResult = validate_and_resolve_user_identity(@application_id, @login_hint, @id_token_hint, @login_hint_token)
				return validationResult unless validationResult.blank?
				
				# validate if user was found
				if(!@identified_user_id.present?) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_user_identification')
		                    	}, status: 400 
							}
				end
				
				return
			end
	
			# get the auth request record
			def getauthinfo_data

  			    ::Rails.logger.info("## getauthinfo_data: auth_req_id => " + @auth_req_id.to_s + ", identified_user_id => " +  @identified_user_id.to_s)
			
				# Search backchannel request
				if(@auth_req_id.present?);
					current_auth_req = BackchannelAuthRequests.where(auth_req_id: @auth_req_id, identified_user_id: @identified_user_id, application_id: @application_id).order("created_at desc");
				else 
					if(@poolingMode == "true")
						current_auth_req = BackchannelAuthRequests.where(identified_user_id: @identified_user_id, application_id: @application_id, status: 'P').order("created_at desc");
					else 
						current_auth_req = BackchannelAuthRequests.where(identified_user_id: @identified_user_id, application_id: @application_id).order("created_at desc");
					end
				end
				
				# SUCCESS 
		        
				resultJson = {requests: []}
				resultJson["requests"] = []
				
			    current_auth_req.each do |t|
					# check expires (force update before return data) 
					check_req_expiry(@params, @server, t) if(t.status == "P")

					item = { 
								auth_req_id: t.auth_req_id,
		                        status: t.status,
								binding_message: t.binding_message,
								scope: t.scope,
								created_at: t.created_at.strftime("%Y-%m-%d %H:%M:%S")
						   }

 					::Rails.logger.info("## getauthinfo_data: sql loop auth_req_id => " + t.auth_req_id + " Item:" + item.to_json + " Array:" + resultJson.to_json)

				    #do stuff 
	 				resultJson["requests"].push(item)
			     end
		
				return { json: resultJson, status: 200 };
		
			end 
	   end
    end
  end
end
