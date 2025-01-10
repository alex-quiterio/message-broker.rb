# Message Broker

A lightweight message broker written in Ruby.

## Features
- Simple and efficient message queueing
- Supports multiple backends
- Easy integration with Ruby applications

## Installation

Ensure you have [Ruby](https://www.ruby-lang.org/) installed.

Install the gem:

```sh
gem install message-broker
```

Or add it to your Gemfile:

```ruby
gem 'message-broker'
```

Then run:

```sh
bundle install
```

## Usage

### Basic Example

```ruby
require 'message_broker'

broker = MessageBroker.new
broker.publish('channel', 'Hello, World!')
message = broker.subscribe('channel')
puts message # => "Hello, World!"
```

## Testing

Run the tests using:

```sh
rake test
```

Or with RSpec:

```sh
rspec
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature-branch`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature-branch`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

