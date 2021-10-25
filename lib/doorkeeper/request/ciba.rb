# frozen_string_literal: true

module Doorkeeper
  module Request
    class Ciba

      attr_reader :server

      delegate :authorize, to: :request

      def initialize(server)
        @server = server
      end

      def request
	    ## TODO GORGES - ver grant_flow.rb e openid_connect.rb para registar
		# XXX validation rules for token
		
		# If the auth_req_id is invalid or was issued to another Client, an invalid_grant error MUST be returned as described in Section 5.2 of [RFC6749].
		#https://datatracker.ietf.org/doc/html/rfc6749#section-5.2

        raise NotImplementedError, "TODO CIBA"
      end
    end
  end
end
