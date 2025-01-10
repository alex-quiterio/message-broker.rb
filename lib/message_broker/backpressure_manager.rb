# frozen_string_literal: true

module MessageBroker
  class BackpressureManager
    attr_reader :check_interval, :queue_size_limit

    def initialize(check_interval: 5, queue_size_limit: 100)
      @check_interval = check_interval
      @queue_size_limit = queue_size_limit
      @last_check_by_topic = {}
      @status_by_topic = {}
      @queues_by_topic = Hash.new { |hash, key| hash[key] = [] }
    end

    def add(topic:, queue:)
      topic = topic.to_sym
      @queues_by_topic[topic] = @queues_by_topic[topic] | [queue]
    end

    def can_process?(topic:)
      topic = topic.to_sym

      if time_to_check?(topic)
        @status_by_topic[topic] = available?(topic)
        @last_check_by_topic[topic] = Time.now
      end

      @status_by_topic[topic]
    end

    def queues_by_topic(topic)
      @queues_by_topic[topic.to_sym]
    end

    private

    def available?(topic)
      biggest_queue_size(topic) < queue_size_limit
    end

    def biggest_queue_size(topic)
      queues_by_topic(topic).map { |q| queue_size(q) }.max || 0
    end

    def queue_size(queue)
      Resque.redis.llen("queue:#{queue}")
    end

    def time_to_check?(topic)
      return true if @last_check_by_topic[topic].nil?

      (Time.now - @last_check_by_topic[topic]) > check_interval
    end
  end
end
