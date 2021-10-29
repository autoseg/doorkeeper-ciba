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
        attr_accessor :id_ciba_token

        def body
		  byebug

		  ::Rails.logger.info("#### CIBA TokenResponse - body extention #################");


          if token.includes_scope? 'openid'
          #  id_token = self.id_token || Doorkeeper::OpenidConnect::IdToken.new(token)

            super
              #.merge(id_token: id_token.as_jws_token)
			  .merge(ciba_param_test: 'xxxxxx')
              .reject { |_, value| value.blank? }
          else
            super
          end
        end
      end
    end
  end
  
  OAuth::TokenResponse.prepend OpenidConnect::Ciba::TokenResponse
end
