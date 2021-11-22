# frozen_string_literal: true

Doorkeeper::OpenidConnect::Ciba.configure do

  # Expiration time for the req_id_token.
  # default_req_id_expiration 600

  # Max Expiration time for the req_id_token (default 1 day).
  # max_req_id_expiration 86400

  # Default minimum wait interval for token execution in poll mode
  #default_poll_interval 5

  # Max bind message size
  # option :max_bind_message_size, default: 128

  # mandatory configuration with the logic to validate the login_hint filled in both backchannel authentication and backchannel complete  
  # must return the id of the user as uuid
  #resolve_user_identity do |login_hint|
  #  user = User.find_by(email: login_hint, email_verified: true)
  #	user.id unless user.nil?
  #end

  # mandatory configuration with the logic to get the e-mail of the user based on auth req id  
  #resolve_email_by_auth_req_id do |auth_req_id|
  #  user = User.select('users.email').joins("inner join backchannel_auth_requests authreq on users.id = authreq.identified_user_id").where("authreq.auth_req_id" => auth_req_id)
  #  user.first.email if user.count > 0
  #end

  # mandatory configuration with the logic to get the userid of the user based on auth req id  
  #resolve_userid_by_auth_req_id do |auth_req_id|
  #  user = User.select('users.id').joins("inner join backchannel_auth_requests authreq on users.id = authreq.identified_user_id").where("authreq.auth_req_id" => auth_req_id)
  #  user.first.id if user.count > 0
  #end

  # mandatory config : add new permission to grant type ciba 
  Doorkeeper.configuration.grant_flows.append("urn:openid:params:grant-type:ciba")

end
