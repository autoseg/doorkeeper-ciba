# frozen_string_literal: true


require 'doorkeeper'
require 'active_model'
require 'json/jwt'

require 'doorkeeper/ciba/config'
require 'doorkeeper/ciba/engine'
require 'doorkeeper/ciba/errors'
require 'doorkeeper/ciba/version'

require 'doorkeeper/ciba/backchannel_authorize'
require 'doorkeeper/ciba/backchannel_complete'

#require 'doorkeeper/ciba/orm/active_record'

require 'doorkeeper/ciba/rails/routes'

module Doorkeeper
	module OpenidConnect
	  module Ciba
	  end
	end
end
