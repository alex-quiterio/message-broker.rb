# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MessageBroker::Message do
  let(:topic) { 'topic' }
  let(:event_name) { 'event_name' }
  let(:payload) do
    {
      key: 'value'
    }
  end

  subject { described_class.new(topic, event_name, payload) }

  context 'bad payload' do
    describe 'not a hash'

    describe 'with event_name key' do
      let(:payload) do
        { event_name: 'my event name' }
      end

      it 'raises MessageBroker::Errors::PayloadReservedKey' do
        expect { subject }.to raise_error(
          MessageBroker::Errors::PayloadReservedKey, 'event_name'
        )
      end
    end
  end
end
