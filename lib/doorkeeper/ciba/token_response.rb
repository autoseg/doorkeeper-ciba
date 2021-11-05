# frozen_string_literal: true

# CIBA
#
# based on doorkeeper-openid_connect/lib/doorkeeper/openid_connect/oauth/token_response.rb
# extend doorkeeper/lib/doorkeeper/oauth/token_response.rb capability, adding the CIBA informations in oauth-token request
# please note that doorkeeper-openid_connect gem does same to add the "id_token" (Open ID JWT) parameter to oauth-token response
#
module Doorkeeper
  module OpenidConnect
    module Ciba
      module TokenResponse
        attr_accessor :id_token

        def body
		  ::Rails.logger.info("#### CIBA TokenResponse - body extention #################");
		  
			# XXX Add here CIBA specific oauth-token response params - grant_type urn:openid:params:grant-type:ciba
            super
        end
      end
    end
  end
  
  OAuth::TokenResponse.prepend OpenidConnect::Ciba::TokenResponse
end
