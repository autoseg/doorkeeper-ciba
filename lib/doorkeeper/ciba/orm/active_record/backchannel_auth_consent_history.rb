# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
    module Ciba
		class BackchannelAuthConsentHistory < ::ActiveRecord::Base
			# constants
			CONSENT_TYPE_APPROVED = 'A'
			CONSENT_TYPE_DISAPPROVED = 'D'
			CONSENT_TYPE_ERROR = 'E'

			# active record info		
			self.table_name = "backchannel_auth_consent_history".to_sym
			validates :auth_req_id, presence: true
			validates :identified_user_id, presence: true
			validates :consent_type, presence: true, acceptance: { accept: ['A', 'D', 'E'] }
							
		 	  #t.uuid :auth_req_id, null: false
			  # the three possible modes for identify the user
			  #t.string :login_hint_token, null: true
		      #t.string :id_token_hint, null: true
		      #t.string :login_hint, null: true
			  # identified user
			  #t.uuid :identified_user_id, null: false
			  #
		      #t.string :consent_type,  null: false
		end
	end
  end
end