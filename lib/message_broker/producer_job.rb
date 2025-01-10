# frozen_string_literal: true

module MessageBroker
  module ProducerJob
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def before_enqueue_send_logger_context(*args)
        context = SDK::Logger.context
        args.first['context'] = context
      end

      def before_perform_receive_logger_context(*args)
        context = args.first['context'] || {}
        SDK::Logger.context = SDK::Logger.context.merge(context)
      end

      def perform(*args)
        # Remove logger context from job arguments
        args.first.try(:delete, 'context')

        process(*args)
      end

      def perform_later(options = {})
        Resque.enqueue(self, options)
      end

      def produce(payload:, key: nil)
        message = MessageBroker::Message.new(topic, event_name, payload)

        # Add logger context to message
        context = {
          context: SDK::Logger.context
                                  .with_indifferent_access
                                  .slice(:user_agent, :request_id, :user_id,
                                         :device_class, :device_id)
        }
        message = message.to_hash.merge(context)

        message_broker.kafka.deliver_message(message.to_json, key: key, topic: topic)
      end

      def topic
        @topic ||= name
                   .gsub("::#{name.demodulize}", '')
                   .underscore.tr('/', '_')
                   .gsub('producers', message_broker.producer_topic_names_prefix)
      end

      def event_name
        @event_name ||= name.demodulize.gsub('Job', '').underscore
      end
    end
  end
end
