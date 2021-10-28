# frozen_string_literal: true

module Doorkeeper
  module Request

    class Ciba < Strategy
       delegate :client, :parameters, to: :server

      def request
		::Rails.logger.info("#### INSIDE Ciba strategy #################")

		# TODO: VALIDATE SCOPES
		@clientXX  = server.client
		@scopesXX  = server.client.scopes
		::Rails.logger.info("#### CIBA: after client XX:" + @clientXX.class.to_s)
	    ::Rails.logger.info("#### CIBA: after client scopes XX:" + @scopesXX.class.to_s)

		resultXX = Doorkeeper::OpenidConnect::Ciba::Token.new(parameters).token
		
		::Rails.logger.info("#### CIBA: return:" + resultXX.class.to_s)

        raise NotImplementedError, "TODO CIBA"
      end
    end
  end
end



