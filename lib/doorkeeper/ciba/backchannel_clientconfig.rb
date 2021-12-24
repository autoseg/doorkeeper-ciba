# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class ClientConfig < CommonBusinessRules
		      def initialize(params, server)
		        @params = params
				@scope = server.client.scopes
				@client= server.client
				@application_id = server.client.id
		      end
		
			  # getauthinfo public method
			  def setClientConfig
			
				# validate parameters
				validationResult = setClientConfig_validate_parameters
				return validationResult unless validationResult.blank?
				#
				# update auth request id
				validationResult = changeClientConfig
				return validationResult unless validationResult.blank?
		      end

			  private

			  # All the error rules are described in https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#auth_error_response
			  def setClientConfig_validate_parameters
	
				::Rails.logger.info("setClientConfig_validate_parameters call")
				
				validTypes = Doorkeeper::OpenidConnect::Ciba::CIBA_VALID_TYPES
				
				# validate mandatory parameters
				if(!@params[:ciba_notify_type].present? || !validTypes.include?(@params[:ciba_notify_type])) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_or_invalid_ciba_notify_type')
		                    	}, status: 400 
							}
				end
				# validate mandatory parameters
				if(!@params[:ciba_notify_endpoint].present?) 
					 return { json: { 
								error: "invalid_request",
		                        error_description: I18n.translate('doorkeeper.openid_connect.ciba.errors.missing_ciba_notify_endpoint')
		                    	}, status: 400 
							}
				end				
				
				return
			end
	
			# get the auth request record
			def changeClientConfig

				 ::Rails.logger.info("## changeClientConfig: client id  => " + @client.id.to_s + " application:" + @client.application.id.to_s)

				application = @client.application 
				application.update(ciba_notify_type: @params[:ciba_notify_type], ciba_notify_endpoint: @params[:ciba_notify_endpoint]);
				application.save
			
				# SUCCESS 
		        return { 
					     json: { 
							ciba_notify_type: @params[:ciba_notify_type],
							ciba_notify_endpoint: @params[:ciba_notify_endpoint]
		                 }, status: 200
					   }

			end 
	   end
    end
  end
end
