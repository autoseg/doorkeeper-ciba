# frozen_string_literal: true

require 'rails/generators/active_record'

module Doorkeeper
	module OpenidConnect
	  module Ciba
	    class MigrationGenerator < ::Rails::Generators::Base
	      include ::Rails::Generators::Migration
	      source_root File.expand_path('templates', __dir__)
	      desc 'Installs Doorkeeper OpenID Connect Ciba migration file.'
	
	      def install
	        migration_template(
	          'create_ciba_backchannel_tables.rb.erb',
	          'db/migrate/create_ciba_backchannel_tables.rb',
	          migration_version: migration_version
	        )
	        migration_template(
	          'add_ciba_reqauthid_to_oauth_token.rb.erb',
	          'db/migrate/add_ciba_reqauthid_to_oauth_token.rb',
	          migration_version: migration_version
	        )
	        migration_template(
	          'add_ciba_asyncendpoint_to_oauth_applications.rb2.erb',
	          'db/migrate/add_ciba_asyncendpoint_to_oauth_applications.rb',
	          migration_version: migration_version
	        )
	      end
	
	      def self.next_migration_number(dirname)
	        ActiveRecord::Generators::Base.next_migration_number(dirname)
	      end
	
	      private
	
	      def migration_version
	        if ActiveRecord::VERSION::MAJOR >= 5
	          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
	        end
	      end
	    end
	  end
	end
end
