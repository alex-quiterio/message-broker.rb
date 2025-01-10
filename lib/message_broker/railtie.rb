# frozen_string_literal: true

module MessageBroker
  class Railtie < Rails::Railtie
    initializer 'logger.initialize' do
      message_broker.logger = ::Rails.logger
    end

    generators do
      require 'generators/message_broker/install/install_generator.rb'
      require 'generators/message_broker/consumer/consumer_generator.rb'
      require 'generators/message_broker/producer/producer_generator.rb'
    end

    rake_tasks do
      load 'tasks/message_broker.rake'
    end
  end
end
