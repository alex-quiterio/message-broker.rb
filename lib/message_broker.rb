# frozen_string_literal: true

require 'message_broker/bus'
require 'message_broker/backpressure_manager'
require 'message_broker/consumer'
require 'message_broker/consumer_job'
require 'message_broker/errors'
require 'message_broker/message'
require 'message_broker/processors/resque_job'
require 'message_broker/producer_job'
require 'message_broker/railtie' if defined?(Rails)
require 'message_broker/version'

require 'logger'

require 'resque'
require 'ruby-kafka'

module MessageBroker
  @kafka = nil
  @logger = nil
  @consumer = nil
  @consumer_group_id = nil
  @consumer_topic_names_prefix = ''
  @producer_topic_names_prefix = ''
  @queue_prefix = ''

  def self.consumer_group_id
    @consumer_group_id
  end

  def self.consumer_group_id=(group_id)
    @consumer_group_id = group_id
  end

  def self.consumer_topic_names_prefix
    @consumer_topic_names_prefix
  end

  def self.consumer_topic_names_prefix=(prefix)
    @consumer_topic_names_prefix = prefix
  end

  def self.kafka
    @kafka
  end

  def self.kafka=(kafka)
    @kafka = kafka
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.producer_topic_names_prefix
    @producer_topic_names_prefix
  end

  def self.producer_topic_names_prefix=(prefix)
    @producer_topic_names_prefix = prefix
  end

  def self.queue_prefix
    @queue_prefix
  end

  def self.queue_prefix=(prefix)
    @queue_prefix = prefix
  end

  def self.bus
    @bus ||= Bus.new
  end

  def self.consumer
    return @consumer if @consumer && @consumer.alive?

    raise Errors::NoKafkaDriver unless kafka
    raise Errors::NoConsumerGroupId unless consumer_group_id

    @consumer = Consumer.new(kafka, bus, consumer_group_id, logger)
  rescue StandardError => e
    logger.fatal('MessageBroker') { e }
    raise(e)
  end
end
