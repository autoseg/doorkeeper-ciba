# frozen_string_literal: true

# CIBA
#
# extend the /doorkeeper-openid_connect/lib/doorkeeper/openid_connect/id_token.rb capability,
# adding the CIBA informations in JWT found in id_token parameter in oauth-token endpoint
#

module Doorkeeper
  module OpenidConnect
    module Ciba
      module IdToken

        def claims
          # mount client_credentials JWT
          @id_token_result = super

          # CIBA specific open_id connect JWT (id_token) params - grant_type urn:openid:params:grant-type:ciba

          #	SAMPLE OUTPUT (JWT decode) - FOUND IN DOC:
          #    {
          #      "iss": "https://server.example.com",
          #      "sub": "248289761001",
          #      "aud": "s6BhdRkqt3",
          #      "email": "janedoe@example.com",
          #      "exp": 1537819803,
          #      "iat": 1537819503,
          #      "at_hash": "Wt0kVFXMacqvnHeyU0001w",
          #      "urn:openid:params:jwt:claim:rt_hash": "sHahCuSpXCRg5mkDDvvr4w",
          #      "urn:openid:params:jwt:claim:auth_req_id":
          #        "1c266114-a1be-4252-8ad1-04986c5b9ac1"
          #    }
          if ((@access_token.includes_scope? 'openid') && (@access_token.ciba_auth_req_id.present?))
            at_hash_token = at_hash_generate(@access_token.token);
            at_hash_refresh_token = at_hash_generate(@access_token.refresh_token) unless @access_token.refresh_token.blank?;
            # in ciba flow, the email of resource owner is got from the "backsession" authorize (saved in the model), not from access_token
            ciba_user_email = resolve_email_by_auth_req_id(@access_token.ciba_auth_req_id);

            ciba_token_clain = {
              "email": ciba_user_email,
              "at_hash": at_hash_token,
              "urn:openid:params:jwt:claim:rt_hash": at_hash_refresh_token,
              "urn:openid:params:jwt:claim:auth_req_id": @access_token.ciba_auth_req_id
            }

            # merge CIBA JWT
            @id_token_result = @id_token_result.merge(ciba_token_clain)
          end

          @id_token_result
        end

        # The at_hash is build according to the following standard:
        #
        # http://openid.net/specs/openid-connect-implicit-1_0.html#IDToken
        #
        # at_hash:
        #   Access Token hash value. If the ID Token is issued with an
        #   access_token in an Implicit Flow, this is REQUIRED, which is the case
        #   for this subset of OpenID Connect. Its value is the base64url encoding
        #   of the left-most half of the hash of the octets of the ASCII
        #   representation of the access_token value, where the hash algorithm
        #   used is the hash algorithm used in the alg Header Parameter of the
        #   ID Token's JOSE Header. For instance, if the alg is RS256, hash the
        #   access_token value with SHA-256, then take the left-most 128 bits and
        #   base64url-encode them. The at_hash value is a case-sensitive string.
        def at_hash_generate(token)
          sha256 = Digest::SHA256.new
          hashed_token = sha256.digest(token)
          first_half = hashed_token[0...hashed_token.length / 2]
          Base64.urlsafe_encode64(first_half).tr('=', '')
        end

        # find the email of end-user based in in auth req id
        def resolve_email_by_auth_req_id(auth_req_id)

          @enduseremail ||= Doorkeeper::OpenidConnect::Ciba.configuration.resolve_email_by_auth_req_id.call(auth_req_id)

        end

      end
    end
  end

  OpenidConnect::IdToken.prepend OpenidConnect::Ciba::IdToken
end
