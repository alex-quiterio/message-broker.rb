# frozen_string_literal: true

module MessageBroker
  class Consumer
    attr_reader :consumer, :logger, :bus

    def initialize(kafka, bus, consumer_group_id, logger)
      logger.info('MessageBroker') { 'Initializing consumer...' }

      @bus = bus
      @consumer = kafka.consumer(group_id: consumer_group_id)
      @logger = logger

      subscribe(bus.topics)
    end

    def alive?
      !consumer.nil?
    end

    def start
      logger.info('MessageBroker') { 'Starting consumer...' }

      loop { }
    end

    def stop
      return unless alive?

      consumer.stop
      @consumer = nil
    end

    private

    def consume
      # We need to define event_name here in order to use it in rescue block
      event_name = nil

      consumer.each_message do |message|
        topic_name = topic_name_without_prefix(message.topic)
        event_name = parse_event_name(message.value)
        logger.debug('MessageBroker') { "topic: #{topic_name}, event: #{event_name}" }

        bus.process(topic: topic_name, event: event_name, message: message.value)
      end
    rescue Kafka::ProcessingError => e
      handle_error(e, event_name)
    end

    def handle_error(exception, event_name)
      if exception.cause.is_a? Errors::QueueSizeLimitReached
        pause_all_partitions(exception.topic)
      else
        log_error(exception, event_name)
        raise exception.cause
      end
    end

    def log_error(exception, event_name)
      logger.error('MessageBroker') do
        MessageBroker::Errors::ProcessingError.new(
          topic: exception.topic,
          partition: exception.partition,
          offset: exception.offset,
          event_name: event_name
        )
      end
    end

    def pause_all_partitions(topic)
      logger.info('MessageBroker') { "Pausing: #{topic}" }

      options = { timeout: 15, max_timeout: 300, exponential_backoff: true }

      message_broker.kafka.partitions_for(topic).times do |partition|
        consumer.pause(topic, partition, options)
      end
    end

    def parse_event_name(message)
      message.match(/event_name\":\"(\w+)/)[1]
    end

    def topic_name_without_prefix(topic_name)
      return topic_name if !message_broker.consumer_topic_names_prefix ||
                           message_broker.consumer_topic_names_prefix.empty?

      topic_name.gsub("#{message_broker.consumer_topic_names_prefix}_", '')
    end

    def subscribe(topics)
      topics.each do |topic|
        topic_with_prefix = [
          message_broker.consumer_topic_names_prefix,
          topic
        ].compact.join('_')

        logger.info('MessageBroker') { "Subscribing to topic: #{topic_with_prefix}" }
        consumer.subscribe(topic_with_prefix.to_s, start_from_beginning: false)
      end
    end
  end
end
