# frozen_string_literal: true

module Doorkeeper
  module Request

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


    class Ciba < Strategy
      #delegate :credentials, :resource_owner, :parameters, :client, to: :server

      def request
	    ## TODO GORGES - ver grant_flow.rb e openid_connect.rb para registar
		# XXX validation rules for token
		
		# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
		#https://datatracker.ietf.org/doc/html/rfc6749#section-5.2

		::Rails.logger.info("#### INSIDE Ciba strategy #################")

        raise NotImplementedError, "TODO CIBA"

 #       @request ||= OAuth::PasswordAccessTokenRequest.new(
 #         Doorkeeper.config,
 #         client,
 #         credentials,
 #         resource_owner,
 #         parameters,
 #       )
      end
    end
  end
end



