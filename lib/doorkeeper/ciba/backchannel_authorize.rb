# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class Authorize
	
	      def initialize(params)
	        @params = params
	      end
	
	      def as_json(*_)
			return authorize
	      end
	
	      private
	
	      def authorize
			# XXX validation rules for token
			
			# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
			#https://datatracker.ietf.org/doc/html/rfc6749#section-5.2
			# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response

			# All the parameters are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#auth_request
			#
			# scope must include openid
			scope = @params[:scope].to_s
			
			# required for ping and push mode (used to notify the callback in these modes) - UNSUPPORTED for v1.0
			client_notification_token = @params[:client_notification_token].to_s
			
			# optional parameter - authentication context classes - UNSUPPORTED for v1.0
 			acr_values = @params[:acr_values].to_s
			
			# Parameters that identify the end-user for whom auth is being requested. At least one must be defined.
			#	
			#As in the CIBA flow the OP does not have an interaction with the end-user through the consumption device, 
			# it is REQUIRED that the Client provides one (and only one) of the hints specified above in the authentication
			# request, that is "login_hint_token", "id_token_hint" or "login_hint".
			#
			if(!(@params[:login_hint_token].present? || @params[:id_token_hint].present? || @params[:login_hint].present?)) 
				 # TODO: check the corret error message
				 return { 
							error: "invalid_request",
	                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.messages.missing_user_identification'),
	                        status: 400
	                    }
				return
			end

			# some identification of the user (implementation specific)
			login_hint_token = @params[:login_hint_token].to_s
			# id of the user
			id_token_hint = @params[:id_token_hint].to_s
			# the value may contain an email address, phone number, account number, subject identifier, username, etc.
			login_hint = @params[:login_hint].to_s
			
			# optional - human readable message to be displayed to the users on both consumption and authorization device
			binding_message = @params[:binding_message].to_s
			
			# optional - secret client code known only by the user - used to prevent unsolicited authentication requests - UNSUPPORTED for v1.0
			user_code = @params[:user_code].to_s
			
			# optional - A positive integer allowing the client to request the expires_in value for the auth_req_id the server will return.
			requested_expiry = @params[:requested_expiry].to_s

	         return { 
							error: "test",
	                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.messages.missing_user_identification'),
	                        status: 400
	                    }
	      end
		end
    end
  end
end
