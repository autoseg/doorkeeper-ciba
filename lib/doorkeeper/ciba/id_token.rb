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
			# mount client_credentials JWT
			@id_token_result = super

			# CIBA specific open_id connect JWT (id_token) params - grant_type urn:openid:params:grant-type:ciba

			#	SAMPLE OUTPUT (JWT decode) - FOUND IN DOC:
			#    {
			#      "iss": "https://server.example.com",
			#      "sub": "248289761001",
			#      "aud": "s6BhdRkqt3",
			#      "email": "janedoe@example.com",
			#      "exp": 1537819803,
			#      "iat": 1537819503,
			#      "at_hash": "Wt0kVFXMacqvnHeyU0001w",
			#      "urn:openid:params:jwt:claim:rt_hash": "sHahCuSpXCRg5mkDDvvr4w",
			#      "urn:openid:params:jwt:claim:auth_req_id":
			#        "1c266114-a1be-4252-8ad1-04986c5b9ac1"
			#    }
			#byebug
			if((@access_token.includes_scope? 'ciba') && (@access_token.ciba_auth_req_id.present?))
				ciba_token_clain = {
		          "urn:openid:params:jwt:claim:auth_req_id": @access_token.ciba_auth_req_id
					# TODO: validate another mandatory parameters for ciba
		        }.merge ClaimsBuilder.generate(@access_token, :id_token)
				# merge CIBA JWT
				@id_token_result = @id_token_result.merge(ciba_token_clain)
			end
			@id_token_result
	      end
		end
	end
  end

  OpenidConnect::IdToken.prepend OpenidConnect::Ciba::IdToken
end
