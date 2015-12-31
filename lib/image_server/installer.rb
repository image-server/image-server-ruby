require 'net/http'
require 'uri'
require 'open-uri'
require 'fileutils'

module ImageServer
  class Installer
    attr_reader :configuration

    def self.install(configuration = ImageServer.configuration)
      new(configuration).install
    end

    def initialize(configuration = ImageServer.configuration)
      @configuration = configuration
    end

    def install
      return unless valid_platform?
      return if installed_latest?

      FileUtils.mkdir_p 'bin'
      File.open(bin_path, 'wb') do |saved_file|
        open(remote_url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
      File.chmod(744, bin_path)
    end

    def valid_platform?
      %w(darwin linux).include?(platform)
    end

    def platform
      `uname -s`.strip.downcase
    end

    def current_version
      '1.15.0'
    end

    def executable_name
      "images-#{platform}-#{current_version}"
    end

    def remote_url
      "https://github.com/image-server/image-server/releases/download/v#{current_version}/#{executable_name}"
    end

    def installed_latest?
      File.exist?(bin_path) && `#{bin_path} --version`.split(' ').last.chomp == current_version
    rescue
      false
    end

    def bin_path
      configuration.path_to_binary
    end
  end
end