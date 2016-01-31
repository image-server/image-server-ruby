require_relative 'adapters/http'

module ImageServer
  class AttachmentUploader
    def initialize(namespace, hash, configuration: ImageServer.configuration)
      @namespace = namespace
      @hash = hash
      @configuration = configuration
    end

    def upload(name, source)
      uploader = Adapters::Http.new(@namespace, source, configuration: @configuration)
      properties_json = uploader.upload(uri(name))
    end

    private

    def uri(name)
      URI.parse("#{@configuration.upload_host}/#{directory_path}/#{name}")
    end

    def directory_path
      Path.directory_path(@namespace, @hash)
    end
  end
end