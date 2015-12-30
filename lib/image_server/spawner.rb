require 'fileutils'
require 'net/http'

module ImageServer
  class Spawner
    attr_accessor :server, :started, :pid, :configuration

    def initialize(configuration: ImageServer.configuration)
      @configuration = configuration
    end

    def start
      unless started?
        self.started = Time.now
        self.pid = fork do
          $stderr.reopen('/dev/null')
          $stdout.reopen('/dev/null')
          server_exec.run
        end
        kill_at_exit
        give_feedback
      end
    end

    def started?
      Net::HTTP.get_response(URI.parse("#{configuration.upload_host}:#{configuration.port}/status_check"))
    rescue StandardError
      nil
    end

    def kill_at_exit
      at_exit do
        puts "image server is stopping"
        Process.kill('TERM', pid)
      end
    end

    def give_feedback
      puts "image server is starting on port #{configuration.port}..." while starting
      puts "image server took #{seconds} seconds to start"
    end

    def seconds
      '%.3f' % (Time.now - started)
    end

    def starting
      response = started?
      return false unless response
      raise "Unable to start image server" unless response.kind_of?(Net::HTTPSuccess)
      false
    rescue Errno::ECONNREFUSED
      true
    end

    private

    def server_exec
      log_file = File.join(configuration.log_directory, 'image_server.log')
      error_file = File.join(configuration.log_directory, 'image_server_errors.log')
      exec("#{configuration.path_to_binary} --port=#{configuration.port} --outputs='' server > #{log_file} 2> #{error_file}")
    end

    def logger
      @@logger ||= ImageServer::Logger.new
    end
  end
end