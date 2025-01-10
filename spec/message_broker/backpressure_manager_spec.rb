# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MessageBroker::BackpressureManager do
  let(:event) { :event_name }
  let(:limit) { 10 }
  let(:instance) { described_class.new(queue_size_limit: limit) }

  describe '.new' do
    subject { instance }

    it { is_expected.to be_an_instance_of(described_class) }
  end

  describe '#add' do
    context 'when adding queues to topic' do
      let(:topic) { 'a' }
      let(:queues) { %w[a a b c d e e] }

      subject { instance.queues_by_topic(topic) }

      before do
        queues.each { |e| instance.add(topic: topic, queue: e) }
      end

      it { is_expected.to match_array(queues.uniq) }
    end
  end

  describe '#can_process?' do
    let(:topic) { 'a' }
    let(:size_by_queue) { { a: 0, b: limit - 1, c: limit - 2 } }
    let(:queues) { size_by_queue.keys }

    subject { instance.can_process?(topic: topic) }

    before do
      queues.each { |e| instance.add(topic: topic, queue: e) }
    end

    context 'when queue size limit is not reached' do
      before do
        allow(instance).to receive(:queue_size) { |q| size_by_queue[q] }
      end

      it { is_expected.to be_truthy }
    end

    context 'when queue size limit is reached' do
      let(:size_by_queue) { { a: 0, b: limit + 1, c: limit + 2 } }

      subject { instance.can_process?(topic: topic) }

      before do
        allow(instance).to receive(:queue_size) { |q| size_by_queue[q] }
      end

      it { is_expected.to be_falsy }
    end

    context 'when cached results are available' do
      subject { instance }

      before { allow(instance).to receive(:time_to_check?).and_return(false) }

      it 'will use cached resuls' do
        is_expected.not_to receive(:queue_size)
      end

      after { instance.can_process?(topic: topic) }
    end

    context 'when cached results are expired' do
      subject { instance }

      before { allow(instance).to receive(:time_to_check?).and_return(true) }

      it 'will load queue sizes from Redis' do
        is_expected.to receive(:queue_size).exactly(queues.count)
      end

      after { instance.can_process?(topic: topic) }
    end
  end
end
