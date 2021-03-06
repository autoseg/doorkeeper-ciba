# frozen_string_literal: true

require 'doorkeeper/ciba/rails/routes/mapping'
require 'doorkeeper/ciba/rails/routes/mapper'

module Doorkeeper
  module OpenidConnect
	module Ciba
	    module Rails
	      class Routes
	        module Helper
	          def use_doorkeeper_openid_connect_ciba(options = {}, &block)
	            Doorkeeper::OpenidConnect::Ciba::Rails::Routes.new(self, &block).generate_routes!(options)
	          end
	        end
	
	        def self.install!
	          ActionDispatch::Routing::Mapper.include Doorkeeper::OpenidConnect::Ciba::Rails::Routes::Helper
	        end
	
	        attr_accessor :routes
	
	        def initialize(routes, &block)
	          @routes = routes
	          @block = block
	        end
	
	        def generate_routes!(options)
	          @mapping = Mapper.new.map(&@block)
	          routes.scope options[:scope] || 'backchannel', as: 'backchannel' do
	            map_route(:authorize, :authorize_routes)
	            map_route(:complete, :complete_routes)
				map_route(:authinfo, :authinfo_routes)
				map_route(:clientconfig, :clientconfig_routes)
				map_route(:testcibacallback, :testcibacallback_routes)
	          end

	          routes.scope options[:scope] || 'backchannel_client', as: 'backchannel_client-client' do
	            map_route(:userconsent, :userconsent_routes)
	          end
	        end
	
	        private
	
	        def map_route(name, method)
	          return if @mapping.skipped?(name)
	
	          mapping = @mapping[name]
	
	          routes.scope controller: mapping[:controllers], as: mapping[:as] do
	            send method
	          end
	        end
	
	        def authorize_routes
	          routes.post :auth, path: 'authorize', as: nil
	        end
	
	        def complete_routes
		      routes.post :complete, path: 'complete', as: nil
	        end

	        def authinfo_routes
		      routes.get :authinfo, path: 'authinfo', as: nil
	        end

	        def userconsent_routes
		      routes.post :userconsent, path: 'userconsent', as: nil
	        end
	        def clientconfig_routes
		      routes.post :clientconfig, path: 'clientconfig', as: nil
	        end
	        def testcibacallback_routes
		      routes.post :testcibacallback, path: 'testcibacallback', as: nil
	        end
	      end
	    end
	end
  end
end
