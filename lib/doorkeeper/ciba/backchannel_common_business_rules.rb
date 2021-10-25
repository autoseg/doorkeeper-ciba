# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    class CommonBusinessRules
			def check_req_expiry(request_record)
					return
			end
			
			# find the id of end-user based in login_hint parameter as e-mail
   		    def resolve_user_identity(login_hint)

   				@identified_user_id ||= Doorkeeper::OpenidConnect::Ciba.configuration.resolve_user_identity.call(login_hint)
	
				#::Rails.logger.info("resolve_user_identity => " + @identified_user_id.to_s)
      		end
	   end
    end
  end
end