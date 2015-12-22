module ImageServer
  class Image

    def initialize(namespace, image_hash, protocol: 'http://', domain: nil, size: nil, format: nil, processing: false, object: nil, default_size: nil)
      @namespace = namespace
      @image_hash = image_hash
      @protocol = protocol
      @domain = domain
      @size = size
      @format = format
      @processing = processing
      @object = object
      @default_size = default_size
    end

    def url(options = {})
      options = options.merge({ processing: @processing })
      image_url_for_version(@default_size, options)
    end

    private

    def image_url_for_version(version, options = {})
      options = {
        protocol: @protocol,
        domain: @domain,
        size:   version,
        format: 'jpg',
      }.merge(options)

      ImageServer::Url.from_hash(@namespace, @image_hash, options)
    end
  end
end