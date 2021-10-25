# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
    module Ciba
		class BackchannelAuthRequests < ::ActiveRecord::Base
			self.table_name = "backchannel_auth_requests".to_sym
			validates :auth_req_id, presence: true
			validates :identified_user_id, presence: true
			validates :expires_in, presence: true
			validates :interval, presence: true
			validates :last_try, presence: true
		
			 #     t.uuid :auth_req_id, null: false
			 #     t.string :status, null: false, default: 'P'
			 #     t.string :binding_message, null: true
			 #     t.string :scope, null: false
			 #	   t.string :client_notification_token, null: true
			 #	   t.string :acr_values, null: true
			 #	   t.string :login_hint_token, null: true
			 #     t.string :id_token_hint, null: true
			 #     t.string :login_hint, null: true
			 #     t.uuid :identified_user_id, null: false
			 #     t.string :user_code, null: true
			 #	   t.number :expires_in, null: false
	  		 #     t.number :interval, null: false
	  		 #	   t.timestamp :last_try, null: false
			 #
			 #     t.timestamps             null: false
		
		end
	end
  end
end
