require 'net/http'
require 'uri'
require_relative '../logger'

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

  module Adapters
    class Http
      class ErrorHandler
        attr_reader :response

        def initialize(http_response)
          @response = http_response
        end

        def handle_errors!
          case response
            when Net::HTTPOK
            when Net::HTTPServiceUnavailable, Net::HTTPGatewayTimeOut
              raise ImageServerUnavailable
            when Net::HTTPNotFound
              error = JSON.parse(response.body)['error']
              if error.start_with?('Unable to download image') || error.start_with?('File is empty')
                raise SourceNotFound, error
              elsif error.end_with?('i/o timeout')
                raise Blocked, error
              elsif error.start_with?('ImageMagick failed')
                raise InvalidSource, error
              elsif error.include?('dial tcp')
                raise ConnectionFailure, error
              else
                # generic case, let's log the error so we can add it later
                # but we consider this a permanent error so tht we don't block processing.
                logger.error "error uploading, but error was not recognized: #{error.inspect}"
                raise UploadError, error
              end
            else
              raise UploadError, response
          end
        end
      end

      attr_reader :url

      def initialize(namespace, source, outputs)
        @namespace = namespace
        @source = source
        @outputs = outputs
      end

      def upload
        uri = URI.parse("#{server_url}/#{@namespace}")

        logger.info "ImageServer::Adapters::Http --> uploading to image server: [#{uri}]"

        params = {outputs: @outputs}
        params[:source] = url if source_is_url?

        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = 60
          body = if source_is_url?
            '{}' # blank body
          elsif @source.class == File
            @source
          elsif Object.const_defined?('ActionDispatch::Http::UploadedFile') && @source.class == ActionDispatch::Http::UploadedFile
            File.open(@source.path).read
          end

          http.post("#{uri.path}?#{uri.query}", body)
        end

        ErrorHandler.new(response).handle_errors!
        @body = JSON.parse(response.body)
      end

      def server_url
        @server_url ||= begin
          url = ImageServer.configuration.upload_host
          url = "http://#{url}" unless url.start_with?('http')
          url
        end
      end

      def valid?
        @body && (image_hash && width && height)
      end

      def image_hash
        @body['hash']
      end

      def width
        @body['width'].to_i
      end

      def height
        @body['height'].to_i
      end

      private

      def logger
        @@logger ||= ImageServer::Logger.new
      end

      def url
        return unless source_is_url?
        @url ||= begin
          @url = @source
          @url = "http:#{@url}" if @url.start_with?('//')
          @url
        end
      end

      def source_is_url?
        @source.is_a?(String) && (@source.start_with?('http') || @source.start_with?('//'))
      end

    end
  end
end