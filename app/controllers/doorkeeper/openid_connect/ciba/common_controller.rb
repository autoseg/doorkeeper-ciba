module Doorkeeper
  module OpenidConnect
    module Ciba
      # commom controller methods
      class CommonController < Doorkeeper::ApplicationMetalController
        # code based on tokens_controller.rb
        def validate_auth_client
          #  The authorization server first validates the client credentials (in
          #  case of a confidential client) and then verifies whether the token
          #  was issued to the client making the revocation request.
          return if server.client

          # If this validation [client credentials / token ownership] fails, the request is
          # refused and the  client is informed of the error by the authorization server as
          # described below.
          #
          # The error presentation conforms to the definition in Section 5.2 of [RFC6749].
          render json: invalid_client_error_response, status: :forbidden
        end

        def invalid_client_error_response
          return {
            error: "invalid_client",
            error_description: I18n.translate('doorkeeper.errors.messages.invalid_client')
          }
        end
      end
    end
  end
end