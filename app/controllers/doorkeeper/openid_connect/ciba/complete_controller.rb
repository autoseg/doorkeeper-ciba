# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/complete
	    class CompleteController < ::Doorkeeper::ApplicationController
	      unless Doorkeeper.configuration.api_only
	        skip_before_action :verify_authenticity_token
	      end
	      before_action -> { doorkeeper_authorize! :openid }
	
	      def complete
	        render json: Doorkeeper::OpenidConnect::Ciba::Complete.new(doorkeeper_token), status: :ok
	      end
	    end
	end
  end
end
