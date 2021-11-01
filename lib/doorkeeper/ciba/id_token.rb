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
			id_token_clain = super

			# XXX Add here CIBA specific open_id connect JWT (id_token) params - grant_type urn:openid:params:grant-type:ciba
	        ciba_token_clain = {
	          ciba_test: '123',
	        }.merge ClaimsBuilder.generate(@access_token, :ciba_token)
			
			byebug
			
			# TODO: add CIBA params
			
				# OUTPUT SAMPLE (found in doc)
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
			
#			JWT decode:
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
			
			
			
			id_token_clain.merge(ciba_token_clain)
	      end
		end
	end
  end

  OpenidConnect::IdToken.prepend OpenidConnect::Ciba::IdToken
end
