# frozen_string_literal: true

module Doorkeeper
	module OpenidConnect
	  module Ciba
	    class Engine < ::Rails::Engine
	      initializer 'doorkeeper.ciba.routes' do
	        Doorkeeper::OpenidConnect::Ciba::Rails::Routes.install!
	      end
	    end
	  end
	end
end
