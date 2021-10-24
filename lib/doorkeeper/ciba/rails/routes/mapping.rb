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
	              complete: 'doorkeeper/openid_connect/ciba/complete'
	            }
	
	            @as = {
	              authorize: :authorize,
	              complete: :complete
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
