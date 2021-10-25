# frozen_string_literal: true

require 'active_support/lazy_load_hooks'

module Doorkeeper
  module OpenidConnect
    module Orm
      module ActiveRecord
        def initialize_models!
          super
          ActiveSupport.on_load(:active_record) do
            require 'doorkeeper/ciba/orm/active_record/backchannel_auth_requests'
            require 'doorkeeper/ciba/orm/active_record/backchannel_auth_consent_history'
          end
        end
      end
    end
  end

  Orm::ActiveRecord.singleton_class.send :prepend, OpenidConnect::Orm::ActiveRecord
end
