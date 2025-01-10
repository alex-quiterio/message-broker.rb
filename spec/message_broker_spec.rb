# frozen_string_literal: true

RSpec.describe message_broker do
  it 'has a version number' do
    expect(MessageBroker::VERSION).not_to be nil
  end
end
