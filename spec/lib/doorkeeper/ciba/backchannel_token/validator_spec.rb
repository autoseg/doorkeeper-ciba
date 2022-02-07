require 'rails_helper'

RSpec.describe Doorkeeper::OpenidConnect::Ciba::Validator do
  include Doorkeeper::Validations
  include Doorkeeper::OAuth::Helpers
  include ActiveSupport::Testing::TimeHelpers

end