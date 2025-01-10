# frozen_string_literal: true

require 'message_broker_launcher'

namespace :message_broker do
  namespace :consumer do
    @pidfile = 'tmp/pids/consumer.pid'
    @pid = message_brokerLauncher.read_pid(@pidfile)

    desc 'Start message_broker consumer'
    task start: :environment do |task, _|
      # Ensure that rake task name is always message_broker:consumer:start
      # even if it was invoked from keepalive or restart tasks
      $PROGRAM_NAME = "#{$PROGRAM_NAME} #{task}"

      if ENV['message_broker_FOREGROUND'] && ENV['message_broker_FOREGROUND'] == 'true'
        message_brokerLauncher.start(@pidfile)
      else
        message_brokerLauncher.daemonize(@pidfile)
      end

    end

    desc 'Stop message_broker consumer'
    task stop: :environment do
      message_brokerLauncher.kill(@pid)
    end

    desc 'Restart message_broker consumer is running'
    task :restart do
      Rake::Task['message_broker:consumer:stop'].invoke if message_brokerLauncher.running?(@pid)
      Rake::Task['message_broker:consumer:start'].invoke
    end

    desc 'Show message_broker consumer status'
    task :status do
      puts "message_broker running: #{message_brokerLauncher.running?(@pid)}"
    end

    desc 'Start message_broker consumer if it\'s not started'
    task :keepalive do
      Rake::Task['message_broker:consumer:start'].invoke
    end
  end
end
