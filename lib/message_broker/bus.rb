# frozen_string_literal: true

module MessageBroker
  class Bus
    attr_reader :semaphore, :topic_subscribers, :bp_manager
    private :semaphore, :topic_subscribers, :bp_manager

    def initialize
      @semaphore = Mutex.new
      @bp_manager = BackpressureManager.new
      @topic_subscribers = Hash.new do |events_by_topic, topic|
        events_by_topic[topic] = Hash.new do |events, name|
          events[name] = []
        end
      end
    end

    def subscribe(topic:, event:, queue: nil, processor:)
      semaphore.synchronize do
        topic_subscribers[topic.to_sym][event.to_sym] << processor
        bp_manager.add(topic: topic, queue: queue)
      end

      nil
    end

    def process(topic:, event:, message:)
      raise Errors::QueueSizeLimitReached unless bp_manager.can_process?(topic: topic)

      subscribers = topic_subscribers[topic.to_sym][event.to_sym]
      subscribers.each { |subscriber| subscriber.call(message) }

      nil
    end

    def topics
      topic_subscribers.keys
    end
  end
end
