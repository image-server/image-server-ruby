require 'net/http'
require 'uri'
require_relative '../logger'
require_relative 'http/error_handler'

module ImageServer
  module Adapters
    class Http
      attr_reader :url

      def initialize(namespace, source, configuration: ImageServer.configuration)
        @namespace = namespace
        @source = source
        @configuration = configuration
      end

      def upload(upload_uri)
        logger.info "ImageServer::Adapters::Http --> uploading to image server: [#{upload_uri}]"

        response = Net::HTTP.start(upload_uri.host, upload_uri.port) do |http|
          request = Net::HTTP::Post.new(upload_uri.request_uri)
          request['Accept'] = "application/json"
          request['Content-Type'] = "application/json"
          request.body = if source_is_url?
            '{}' # blank body
          elsif @source.is_a?(File)
            @source
          elsif @source.respond_to?(:path)
            File.open(@source.path).read
          else
            raise('Not supported')
          end

          http.read_timeout = 60
          http.request(request)
        end

        ErrorHandler.new(response).handle_errors!
        @body = JSON.parse(response.body)
      rescue Errno::ECONNREFUSED => e
        raise ImageServerUnavailable
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

      def source_is_url?
        return false unless @source.is_a?(String)

        @source.start_with?('http') || @source.start_with?('//')
      end

    end
  end
end