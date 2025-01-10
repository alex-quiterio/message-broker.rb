# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'message_broker/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'message-broker.rb'
  s.version     = MessageBroker::VERSION
  s.authors     = ['alex quiterio']
  s.email       = ['alexandre.quiterio@pm.me']
  s.homepage    = 'https://github.com/alex-quiterio/message_broker.rb'
  s.summary     = 'Kafka to Resque'
  s.description = 'Converts Kafka messages into Resque jobs'
  s.license     = 'MIT'

  s.files       = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  s.add_development_dependency 'rubocop', '>= 0.50'

  s.add_dependency 'resque', '>= 1.26.0'
  s.add_dependency 'ruby-kafka', '~> 0.6.0'
end
