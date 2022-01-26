# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
    module Ciba
      def self.configure(&block)
        if Doorkeeper.configuration.orm != :active_record
          raise Errors::InvalidConfiguration, 'Doorkeeper OpenID Connect currently only supports the ActiveRecord ORM adapter'
        end

        @config = Config::Builder.new(&block).build
      end

      def self.configuration
        @config || (raise Errors::MissingConfiguration)
      end

      class Config
        class Builder
          def initialize(&block)
            @config = Config.new
            instance_eval(&block)
          end

          def build
            @config
          end
        end

        module Option
          # Defines configuration option
          #
          # When you call option, it defines two methods. One method will take place
          # in the +Config+ class and the other method will take place in the
          # +Builder+ class.
          #
          # The +name+ parameter will set both builder method and config attribute.
          # If the +:as+ option is defined, the builder method will be the specified
          # option while the config attribute will be the +name+ parameter.
          #
          # If you want to introduce another level of config DSL you can
          # define +builder_class+ parameter.
          # Builder should take a block as the initializer parameter and respond to function +build+
          # that returns the value of the config attribute.
          #
          # ==== Options
          #
          # * [:+as+] Set the builder method that goes inside +configure+ block
          # * [+:default+] The default value in case no option was set
          #
          # ==== Examples
          #
          #    option :name
          #    option :name, as: :set_name
          #    option :name, default: 'My Name'
          #    option :scopes builder_class: ScopesBuilder
          #
          def option(name, options = {})
            attribute = options[:as] || name
            attribute_builder = options[:builder_class]

            Builder.instance_eval do
              define_method name do |*args, &block|
                # is builder_class option being used?
                value = if attribute_builder
                          attribute_builder.new(&block).build
                        else
                          block || args.first
                        end

                @config.instance_variable_set(:"@#{attribute}", value)
              end
            end

            define_method attribute do |*_|
              if instance_variable_defined?(:"@#{attribute}")
                instance_variable_get(:"@#{attribute}")
              else
                options[:default]
              end
            end

            public attribute
          end

          def extended(base)
            base.send(:private, :option)
          end
        end

        extend Option

        # Expiration time for the req_id_token (default 600 seconds).
        option :default_req_id_expiration, default: 600
        # Max Expiration time for the req_id_token (default 1 day).
        option :max_req_id_expiration, default: 86400

        # Default minimum wait interval for token execution in poll mode
        option :default_poll_interval, default: 5
        # Max bind message size
        option :max_bind_message_size, default: 128

        # mandatory configuration with the logic to validate the login_hint filled in both backchannel authentication and backchannel complete
        # must return the id of the user as uuid
        option :resolve_user_identity, default: lambda { |*_|
          raise Errors::InvalidConfiguration, 'mandatory parameter "resolve_user_identity" is not configured'
        }

        # mandatory configuration with the logic to get the e-mail of the user based on auth req id
        option :resolve_email_by_auth_req_id, default: lambda { |*_|
          raise Errors::InvalidConfiguration, 'mandatory parameter "resolve_email_by_auth_req_id" is not configured'
        }

        # mandatory configuration with the logic to get the userid of the user based on auth req id
        option :resolve_userid_by_auth_req_id, default: lambda { |*_|
          raise Errors::InvalidConfiguration, 'mandatory parameter "resolve_userid_by_auth_req_id" is not configured'
        }

      end
    end
  end
end
