# frozen_string_literal: true

module Doorkeeper
  module Request
    class Ciba < Strategy

      delegate :client, :parameters, to: :server

      def request
		::Rails.logger.info("#### INSIDE Ciba oauth-token strategy #################")

		# excute Token inside backchannel_token.rb and return to controller
		@request ||= Doorkeeper::OpenidConnect::Ciba::Token.new(
		  Doorkeeper.config,
          client,
          parameters,
		)
      end
    end
  end
end



