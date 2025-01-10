# frozen_string_literal: true

require 'message_broker'

# RakeDaemon helps to daemonize simple rake task
module MessageBrokerLauncher
  def self.start(pidfile)
    pid = read_pid(pidfile)
    abort("message_broker: Consumer with PID #{pid} already exists") if running?(pid)

    Signal.trap('TERM') { |sig| stop(pidfile, sig) }
    Signal.trap('INT')  { |sig| stop(pidfile, sig) }

    create_pidfile(pidfile)
    message_broker.consumer.start
  end

  def self.stop(pidfile, reason = nil)
    message_broker.consumer.stop
    remove_pidfile(pidfile)
    puts "message_broker: Consumer stopped with SIG #{reason}"
  end

  def self.daemonize(pidfile)
    Process.daemon(true, true)
    start(pidfile)
  end

  def self.kill(pid)
    running?(pid) || abort('message_broker: Consumer is not running')

    message_broker.logger.info('MessageBroker') { 'Stopping consumer...' }

    Process.kill('TERM', pid)
    Process.waitpid(pid)
  end

  def self.read_pid(pidfile)
    return unless File.file?(pidfile)

    File.read(pidfile).to_i
  end

  def self.running?(pid)
    return false if pid.blank?

    return true if Process.kill(0, pid)
  rescue Errno::ESRCH
    false
  end

  def self.create_pidfile(pidfile)
    File.open(pidfile, 'w') { |f| f << Process.pid }
  end

  def self.remove_pidfile(pidfile)
    `rm -rf #{pidfile}`
  end
end
