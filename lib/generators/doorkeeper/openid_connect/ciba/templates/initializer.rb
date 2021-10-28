# frozen_string_literal: true

Doorkeeper::OpenidConnect::Ciba.configure do

  # Expiration time for the req_id_token.
  # default_req_id_expiration 600

  # Default minimum wait interval for token execution in poll mode
  #default_poll_interval 5

  # Max bind message size
  # option :max_bind_message_size, default: 128

  # mandatory configuration with the logic to validate the login_hint filled in both backchannel authentication and backchannel complete  
  # must return the id of the user as uuid
  #resolve_user_identity do |login_hint|
  #  user = User.find_by(email: login_hint)
  #	user.id unless user.nil?
  #end

  # mandatory config : add new permission to new grant type 
  Doorkeeper.configuration.grant_flows.append("urn:openid:params:grant-type:ciba")

end
