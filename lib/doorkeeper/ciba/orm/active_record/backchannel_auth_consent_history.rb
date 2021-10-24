# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
    module Ciba
	    module Orm
	      module ActiveRecord
			class BackchannelAuthConsentHistory < ApplicationRecord
			
			#      t.uuid :auth_req_id, null: false, :primary => true
			#      t.string :consent_user_id, null: true
			#      t.string :consent_type,  null: false
			
			#      t.timestamps             null: false
			end
		end
	end
  end
end