# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class TestcibacallbackController < ::ApplicationController

		# JUST TO TEST / DEBUG THE CIBA CALLBACK
	    def testcibacallback
			
			::Rails.logger.info("##### testcibacallback BEGIN ###################################")
			::Rails.logger.info("##### HEADERS: " + request.headers.to_h.select { |k,v|
					  ['HTTP','CONTENT','AUTHORIZATION'].any? { |s| k.to_s.starts_with? s }
					}.to_s)
			::Rails.logger.info("##### PARAMS: " + params.to_s)
			
			::Rails.logger.info("##### BODY: " + request.body.read)
			
			::Rails.logger.info("##### testcibacallback END #####################################")

			# PING MODE
			# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#ping_callback
			#If the Client is registered in Ping mode, the OpenID Provider will send an HTTP POST Request to the Client Notification Endpoint after a successful or failed end-user authentication.

			# PING MODE SAMPLE CALL			
			#    POST /cb HTTP/1.1
			#    Host: client.example.com
			#    Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
			#    Content-Type: application/json
		    #	
			#    {
			#     "auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1"
			#    }


			# PUSH MODE
			# https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-03.html#successful_token_push
			# f the Client is registered in Push mode and the user is well authenticated and has authorized the request, the OpenID Provider delivers a payload that includes an ID Token, 
			# an Access Token and, optionally, a Refresh Token to the Client Notification Endpoint.
			          
			#	PUSH MODE SAMPLE CALL
			#    POST /cb HTTP/1.1
			#    Host: client.example.com
			#    Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
			#    Content-Type: application/json
			#
			#    {
			#     "auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1",
			#     "access_token": "G5kXH2wHvUra0sHlDy1iTkDJgsgUO1bN",
			#     "token_type": "Bearer",
			#     "refresh_token": "4bwc0ESC_IAhflf-ACC_vjD_ltc11ne-8gFPfA2Kx16",
			#     "expires_in": 120,
			#     "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2NzcyNiJ9.eyJpc3MiOiJ
			#       odHRwczovL3NlcnZlci5leGFtcGxlLmNvbSIsInN1YiI6IjI0ODI4OTc2MTAwMS
			#       IsImF1ZCI6InM2QmhkUmtxdDMiLCJlbWFpbCI6ImphbmVkb2VAZXhhbXBsZS5jb
			#       20iLCJleHAiOjE1Mzc4MTk4MDMsImlhdCI6MTUzNzgxOTUwMywiYXRfaGFzaCI6
			#       Ild0MGtWRlhNYWNxdm5IZXlVMDAwMXciLCJ1cm46b3BlbmlkOnBhcmFtczpqd3Q
			#       6Y2xhaW06cnRfaGFzaCI6InNIYWhDdVNwWENSZzVta0REdnZyNHciLCJ1cm46b3
			#       BlbmlkOnBhcmFtczpqd3Q6Y2xhaW06YXV0aF9yZXFfaWQiOiIxYzI2NjExNC1hM
			#       WJlLTQyNTItOGFkMS0wNDk4NmM1YjlhYzEifQ.SGB5_a8E7GjwtoYrkFyqOhLK6
			#       L8-Wh1nLeREwWj30gNYOZW_ZB2mOeQ5yiXqeKJeNpDPssGUrNo-3N-CqNrbmVCb
			#       XYTwmNB7IvwE6ZPRcfxFV22oou-NS4-3rEa2ghG44Fi9D9fVURwxrRqgyezeD3H
			#       HVIFUnCxHUou3OOpj6aOgDqKI4Xl2xJ0-kKAxNR8LljUp64OHgoS-UO3qyfOwIk
			#       IAR7o4OTK_3Oy78rJNT0Y0RebAWyA81UDCSf_gWVBp-EUTI5CdZ1_odYhwB9OWD
			#       W1A22Sf6rmjhMHGbQW4A9Z822yiZZveuT_AFZ2hi7yNp8iFPZ8fgPQJ5pPpjA7u
			#       dg"
			#    }
        



			render json: {'test': 'ok'}, status:200
	    end
	  end
	end
  end
end









