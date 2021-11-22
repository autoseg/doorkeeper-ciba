# frozen_string_literal: true

module Doorkeeper
  module Request
    class Ciba < Strategy

      delegate :client, :parameters, to: :server

      def request
		::Rails.logger.info("#### INSIDE Ciba oauth-token strategy #################")

		# TODO: remove CONSENT_NOTITY_LOGIC if defined in params to avoid conflict with PUSH logic

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



