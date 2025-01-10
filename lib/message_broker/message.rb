# frozen_string_literal: true

module MessageBroker
  class Message
    def initialize(topic, event_name, payload)
      raise Errors::PayloadNotAHash unless payload.is_a?(Hash)
      raise Errors::PayloadReservedKey, 'event_name' if contains_event_name(payload)

      @message = {
        topic: topic,
        event_name: event_name,
        payload: payload,
        produced_at: Time.now,
        uuid: SecureRandom.uuid
      }
    end

    def to_hash
      @message
    end

    def to_json
      to_hash.to_json
    end

    private

    def contains_event_name(payload)
      /event_name\":/ =~ MultiJson.dump(payload)
    end
  end
end
