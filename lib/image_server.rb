require 'image_server/version'
require_relative 'image_server/logger'
require_relative 'image_server/configuration'
require_relative 'image_server/uploader'

module ImageServer
  class << self
    def logger
      @logger ||= Logger.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   ImageServer.configure do |config|
    #     config.logger = Rails.logger
    #     config.upload_host = '127.0.0.1'
    #   end
    def configure
      yield(configuration) if block_given?
    end
  end
end
