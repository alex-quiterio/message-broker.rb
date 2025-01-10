# frozen_string_literal: true

module MessageBroker
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'message_broker.rb.erb', 'config/initializers/message_broker.rb'
      end

      def setup_directories
        empty_directory 'app/jobs'
        empty_directory 'app/jobs/consumers'
        empty_directory 'app/jobs/producers'
      end
    end
  end
end
