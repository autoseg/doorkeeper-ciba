# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Token < CommonBusinessRules
		      def initialize(params)
		        @params = params
		      end
		
		
				# Implementation of ciba (urn:openid:params:grant-type:ciba) grant_type for oauth token
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
		
		      # AUTH: The Client MUST be authenticated as specified in Section 9 of [OpenID.Core] --> https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
		
			  # token public method
			  # DOC: ttps://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#token_request
			  def token
				# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#rfc.section.10.1
				
				::Rails.logger.info("#### INSIDE CIBA TOKEN #################:" + @params);
				
				@grant_type = @params[:grant_type].to_s
				
				# auth_req_id				
				@auth_req_id = @params[:auth_req_id].to_s;
				
				# UNSUPPORTED for v1.0 # mutual required (user identity group)- some identification of the user (implementation specific)
				@login_hint_token = @params[:login_hint_token].to_s
				#
				# mutual required (user identity group)- id of a valid token of an user
				@id_token_hint = @params[:id_token_hint].to_s
				#
				# mutual required (user identity group) - the value may contain an email address, phone number, account number, subject identifier, username, etc.
				@login_hint = @params[:login_hint].to_s
				
				# TODO: scope must include openid
				@scope = @params[:scope].to_s
				#
				# validate parameters
				validationResult = token_validate_parameters
				return validationResult unless validationResult.blank?
				#
				# update auth request id
				getResult = get_auth_request_id
				return getResult unless getResult.blank?
				
				
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
				
				::Rails.logger.info("#### INSIDE CIBA TOKEN : SUCESS");
				
				# TODO - access_token, refresh_token, expires_in, id_token
		        return { 
					     json: { 
							auth_req_id: @auth_req_id, # TODO: remove, not part of spec
	                        access_token: @access_token,
							token_type: "Bearer",
							expires_in: @expires_in, 
							id_token: @id_token
		                 }, status: 200
					   }
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def token_validate_parameters
	
				::Rails.logger.info("complete_validate_parameters call")
	
				validationResult = validate_and_resolve_user_identity(@login_hint, @id_token_hint, @login_hint_token)
				return validationResult unless validationResult.blank?
				
				validationResult = validate_scope(@scope)
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
			def get_auth_request_id

				 ::Rails.logger.info("## update_auth_request_id_with_history: auth_req_id => " + @auth_req_id.to_s + ", identified_user_id => " +  @identified_user_id.to_s)
			
				# Search the backchannel request with status different than PENDING
				@current_auth_req = BackchannelAuthRequests.find_by(auth_req_id: @auth_req_id, identified_user_id: @identified_user_id, :status.not => BackchannelAuthRequests::STATUS_PENDING);

				if(! current_auth_req.present?) 
				# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
						 return { json: { 
									error: "invalid_grant",
			                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.invalid_grant')
			                    	}, status: 400 
								}
				else
					::Rails.logger.info("## RETURNING BackchannelAuthRequests WITH auth_req_id:" +  @auth_req_id + " status: " + current_auth_req[:status])
					# TODO: VALIDATE the possible status, 
				end
				return
			end 
	   end
    end
  end
end
