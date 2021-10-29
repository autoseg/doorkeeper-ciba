# frozen_string_literal: true

# CIBA
#
# extend the /doorkeeper-openid_connect/lib/doorkeeper/openid_connect/id_token.rb capability,
# adding the CIBA informations in JWT found in id_token parameter in oauth-token endpoint
#
module Doorkeeper
  module OpenidConnect
    module Ciba
	    module IdToken
	      def claims
	        ciba_token_clain = {
	          ciba_test: '123',
	        }.merge ClaimsBuilder.generate(@access_token, :ciba_token)

			id_token_clain = super
			
			byebug
			id_token_clain.merge(ciba_token_clain)
	      end
		end
	end
  end

  OpenidConnect::IdToken.prepend OpenidConnect::Ciba::IdToken
end
