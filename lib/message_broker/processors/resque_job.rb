# frozen_string_literal: true

module MessageBroker
  module Processors
    # ResqueJob Processor defines an interface to use with message_broker,
    # maybe we should change it for one processor that use ActiveJob interface
    class ResqueJob
      def initialize(klass)
        @klass = klass
      end

      def call(message)
        ::Resque.enqueue(@klass, message)
      end
    end
  end
end
