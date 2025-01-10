# frozen_string_literal: true

module MessageBroker
  module ConsumerJob
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def before_perform(*args)
        json = JSON.parse(args.first)
        context = json['context'] || {}
        SDK::Logger.context = SDK::Logger.context.merge(context)
      end

      def perform(*args)
        process JSON.parse(args.first)
      end

      # processor named argument gives an option to pass a block or a class
      # for custom message process scenario
      # TODO: Move default processor to config
      def subscribe(topic:, event:, processor: MessageBroker::Processors::ResqueJob.new(self))
        raise Errors::QueueNotDefined, 'Please define @queue before subscribe' if @queue.nil?

        message_broker.bus.subscribe(topic: topic, event: event, queue: @queue, processor: processor)
      end
    end
  end
end
