require 'image_server/version'
require_relative 'image_server/logger'
require_relative 'image_server/configuration'
require_relative 'image_server/uploader'
require_relative 'image_server/attachment_uploader'
require_relative 'image_server/image'
require_relative 'image_server/url'

module ImageServer
  class PermanentFailure < StandardError; end
  class TemporaryFailure < StandardError; end

  class ImageServerUnavailable < TemporaryFailure; end
  class StoreConcurrencyExceeded < TemporaryFailure; end

  class UploadError < PermanentFailure; end
  class SourceNotFound < PermanentFailure; end
  class InvalidSource < PermanentFailure; end
  class Blocked < PermanentFailure; end
  class ConnectionFailure < PermanentFailure; end

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
