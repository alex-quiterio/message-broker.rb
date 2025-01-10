# frozen_string_literal: true

module MessageBroker
  module Errors
    class NoBlockGiven < ArgumentError; end
    class NoConsumerGroupId < ArgumentError; end
    class NoKafkaDriver < ArgumentError; end
    class NoSubscribersName < ArgumentError; end
    class NoTopicName < ArgumentError; end
    class PayloadNotAHash < ArgumentError; end
    class PayloadReservedKey < ArgumentError; end
    class QueueSizeLimitReached < StandardError; end
    class QueueNotDefined < StandardError; end

    # Raised when message cannot be processed
    class ProcessingError < StandardError
      attr_reader :topic, :partition, :offset, :event_name

      def initialize(topic:, partition:, offset:, event_name:)
        @topic = topic
        @partition = partition
        @offset = offset
        @event_name = event_name
      end

      def to_s
        " topic: #{topic}, partition: #{partition}, offset: #{offset}, event_name: #{event_name}"
      end
    end
  end
end
