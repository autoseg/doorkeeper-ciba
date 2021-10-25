# frozen_string_literal: true

module Doorkeeper
  module Request
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



