# frozen_string_literal: true

require 'spec_helper'
require 'fakeredis'

RSpec.describe MessageBroker::Bus do
  let(:topics) { %i[a b c d] }
  let(:event) { :event_name }
  let(:block) { ->(_) { 'do something' } }
  let(:instance) { described_class.new }

  subject { instance }

  describe '.new' do
    it { is_expected.to be_an_instance_of(described_class) }
  end

  describe '#topics' do
    context 'when different topics subscriptions' do
      before do
        topics.each do |topic|
          instance.subscribe topic: topic, event: event, processor: block
        end
      end

      subject { instance.topics }

      it { is_expected.to eq topics }
    end
  end

  describe '#process' do
    let(:block2) { ->(_) { 'second block' } }

    context 'multiple handlers for the same topic' do
      before do
        instance.subscribe topic: :t1, event: event, processor: block
        instance.subscribe topic: :t1, event: event, processor: block2
      end

      it 'calls all handlers even if they are for the same topic' do
        expect(block).to receive(:call)
        expect(block2).to receive(:call)
        instance.process(topic: :t1, event: event, message: 'some')
      end
    end

    context 'subscriptions to different topics' do
      before do
        instance.subscribe topic: :t1, event: event, processor: block
        instance.subscribe topic: :t2, event: event, processor: block2
      end

      it 'only calls the handler for the processing topic' do
        expect(block).to receive(:call)
        expect(block2).not_to receive(:call)
        instance.process(topic: :t1, event: event, message: 'some')
      end
    end
  end
end
