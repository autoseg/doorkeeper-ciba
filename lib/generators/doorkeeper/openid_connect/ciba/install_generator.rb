# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
    module Ciba
      class InstallGenerator < ::Rails::Generators::Base
        include ::Rails::Generators::Migration
        source_root File.expand_path('templates', __dir__)
        desc 'Installs Doorkeeper Open Id Connect CIBA Support.'

        def install
          template 'initializer.rb', 'config/initializers/doorkeeper_openid_connect_ciba.rb'
          puts("ALERT: Please edit config/initializers/doorkeeper_openid_connect_ciba.rb and configure mandatory entries")
          #copy_file File.expand_path('../../../../../config/locales/en.yml', __dir__), 'config/locales/doorkeeper_openid_connect_ciba.en.yml'
          route 'use_doorkeeper_openid_connect_ciba'
        end
      end
    end
  end
end
