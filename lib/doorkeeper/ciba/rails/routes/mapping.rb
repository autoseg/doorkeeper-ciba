# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
	  module Ciba
	    module Rails
	      class Routes
	        class Mapping
	          attr_accessor :controllers, :as, :skips
	
	          def initialize
	            @controllers = {
	              authorize: 'doorkeeper/openid_connect/ciba/authorize',
	              complete: 'doorkeeper/openid_connect/ciba/complete',
				  authinfo: 'doorkeeper/openid_connect/ciba/authinfo',
				  clientconfig: 'doorkeeper/openid_connect/ciba/clientconfig', 
				  userconsent: 'doorkeeper/openid_connect/ciba/userconsent',
				  testcibacallback: 'doorkeeper/openid_connect/ciba/testcibacallback'
	            }
	
	            @as = {
	              authorize: :authorize,
	              complete: :complete,
				  authinfo: :authinfo,
				  clientconfig: :clientconfig,
				  userconsent: :userconsent,
				  testcibacallback: :testcibacallback
	            }
	
	            @skips = []
	          end
	
	          def [](routes)
	            {
	              controllers: @controllers[routes],
	              as: @as[routes]
	            }
	          end
	
	          def skipped?(controller)
	            @skips.include?(controller)
	          end
	        end
	      end
	  end
    end
  end
end
