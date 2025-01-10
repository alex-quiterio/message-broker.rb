# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MessageBroker::Consumer do
  let(:kafka) { double }
  let(:bus) { double(topics: %w[a b c d]) }
  let(:kafka_consumer) { double }
  let(:consumer_id) { 'ms_consumer' }
  let(:instance) do
    described_class.new(kafka, bus, consumer_id, Logger.new(nil))
  end

  before do
    expect(kafka).to receive(:consumer)
      .with(group_id: consumer_id) { kafka_consumer }

    bus.topics.each do |topic|
      expect(kafka_consumer).to receive(:subscribe)
        .with(
          "#{message_broker.consumer_topic_names_prefix}_#{topic}",
          start_from_beginning: false
        )
    end
  end

  subject { instance }

  describe '.new' do
    it { is_expected.to be_an_instance_of(described_class) }
  end

  describe '#alive?' do
    subject { instance.alive? }

    context 'fresh instance' do
      it { is_expected.to be_truthy }
    end

    context 'after stop' do
      before do
        expect(kafka_consumer).to receive(:stop)
        instance.stop
      end

      it { is_expected.to be_falsey }
    end

    context 'consumer doesn\'t exist' do
      before do
        expect(instance).to receive(:consumer) { nil }
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#start' do
    before do
      allow(instance).to receive(:loop).and_yield
    end

    after do
      instance.start
    end

    subject { instance.consumer }

    it { is_expected.to receive(:each_message) }
  end

  describe '#stop' do
    before do
      expect(kafka_consumer).to receive(:stop)
      instance.stop
    end

    describe 'consumer attribute' do
      subject { instance.consumer }

      it { is_expected.to be_nil }
    end
  end
end
