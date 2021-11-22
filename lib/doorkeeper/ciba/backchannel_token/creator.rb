# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
	    module ClientCredentials
	      class Creator
	        def call(client, scopes, attributes = {})
			 #byebug
	          existing_token = nil
	
	          if lookup_existing_token?
	            existing_token = find_existing_token_for(client, scopes)
	            return existing_token if server_config.reuse_access_token && existing_token&.reusable?
	          end
	
	          with_revocation(existing_token: existing_token) do
   			    owner_id = resolve_userid_by_auth_req_id(attributes[:ciba_auth_req_id]);
	            server_config.access_token_model.find_or_create_for(
	              application: client,
	              resource_owner: owner_id,
	              scopes: scopes,
	              **attributes,
	            )
	          end
	        end
	
	        private
	
	        def with_revocation(existing_token:)
	          if existing_token && server_config.revoke_previous_client_credentials_token?
	            existing_token.with_lock do
	              raise Errors::DoorkeeperError, :invalid_token_reuse if existing_token.revoked?
	
	              existing_token.revoke
	
	              yield
	            end
	          else
	            yield
	          end
	        end
	
	        def lookup_existing_token?
	          server_config.reuse_access_token ||
	            server_config.revoke_previous_client_credentials_token?
	        end
	
	        def find_existing_token_for(client, scopes)
	          server_config.access_token_model.matching_token_for(client, nil, scopes)
	        end
	
	        def server_config
	          Doorkeeper.config
	        end

			# find the userid of end-user based in in auth req id
   		    def resolve_userid_by_auth_req_id(auth_req_id)

   				Doorkeeper::OpenidConnect::Ciba.configuration.resolve_userid_by_auth_req_id.call(auth_req_id)
	
      		end
	      end
	    end
	  end
	end
end
