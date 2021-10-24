# frozen_string_literal: true

module Doorkeeper
  module Request
    class Ciba
## TODO GORGES - ver grant_flow.rb para registar

      attr_reader :server

      delegate :authorize, to: :request

      def initialize(server)
        @server = server
      end

      def request
        raise NotImplementedError, "TODO CIBA"
      end
    end
  end
end
