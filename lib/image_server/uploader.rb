require_relative 'adapters/http'

module ImageServer
  class Uploader
    def initialize(namespace, source, outputs, configuration: ImageServer.configuration)
      @namespace = namespace
      @source = source
      @outputs = outputs
      @configuration = configuration
    end

    def upload(force: false)
      return existing_image_property if existing_image_property && !force
      uploader = Adapters::Http.new(@namespace, @source, configuration: @configuration)
      properties_json = uploader.upload(uri)

      find_or_create_image_property(properties_json)
    rescue PermanentFailure => e
      raise UploadError.new(e.message)
    end

    private

    def uri
      uri = URI.parse("#{@configuration.upload_host}/#{@namespace}")
      params = {outputs: @outputs}
      params[:source] = url if source_is_url?
      uri.query = URI.encode_www_form(params)
      uri
    end

    def find_or_create_image_property(properties)
      attributes = {
        width: properties['width'],
        height: properties['height'],
        image_url: url,
        namespace: @namespace
      }
      ip = ImageProperty.where(image_hash: properties['hash'], namespace: @namespace).first || ImageProperty.new(image_hash: properties['hash'])
      ip.assign_attributes(attributes)
      ip.save!
      ip
    end

    def url
      return @source if source_is_url?
    end

    def existing_image_property
      return unless url
      @existing_image_property ||= ImageProperty.where(namespace: @namespace).where('lower(image_url) = lower(?)', url).first
    end

    def source_is_url?
      @source.is_a?(String) && (@source.start_with?('http') || @source.start_with?('//'))
    end
  end
end