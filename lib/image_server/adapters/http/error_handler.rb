module ImageServer
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

        private

        def logger
          @@logger ||= ImageServer::Logger.new
        end
      end
    end
  end
end

