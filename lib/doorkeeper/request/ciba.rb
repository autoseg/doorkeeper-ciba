# frozen_string_literal: true

module Doorkeeper
  module Request
    class Ciba < Strategy

      delegate :client, :parameters, to: :server

      def request
		::Rails.logger.info("#### INSIDE Ciba strategy #################")

		@request ||= Doorkeeper::OpenidConnect::Ciba::Token.new(
		  Doorkeeper.config,
          server.client,
          parameters,
		)
      end
    end
  end
end



