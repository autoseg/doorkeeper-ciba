# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    module ClientCredentials
	      class Issuer
	        attr_reader :token, :validator, :error
	
	        def initialize(server, validator)
	          @server = server
	          @validator = validator
	        end
		
	        def create(client, scopes, params)
	          if validator.valid?
	            @token = create_token(client, scopes, params)
	            @error = :server_error unless @token
	          else
	            @token = false
	            @error = validator.error
	          end
	
			  #byebug
	
	          @token
	        end
	
	        private
	
			# create token in database
	        def create_token(client, scopes, params)
			  #byebug
	          context = Doorkeeper::OAuth::Authorization::Token.build_context(
	            client,
	            Doorkeeper::OpenidConnect::Ciba::GRANT_TYPE_CIBA,
	            scopes,
	            nil,
	          )

	          ttl = Doorkeeper::OAuth::Authorization::Token.access_token_expires_in(@server, context)
	
			  creator = Doorkeeper::OpenidConnect::Ciba::ClientCredentials::Creator.new
	
		      #create the token in database
	          creator.call(
	            client,
	            scopes,
	            use_refresh_token: Doorkeeper.config.refresh_token_enabled?,
	            expires_in: ttl,
				ciba_auth_req_id: params['auth_req_id']
	          )
	        end
	      end
	    end
	end
  end
end
