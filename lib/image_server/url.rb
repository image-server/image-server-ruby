module ImageServer
  class Url
    # Pregenerated images
    # full_size.jpg, x100-q95.jpg
    def self.from_hash(namespace, image_hash, size: 'full_size', format: 'jpg', protocol: ImageServer.configuration.cdn_protocol, domain: nil, processing: false)
      return if image_hash.to_s.empty?
      domain ||= self.domain(image_hash)

      url = "#{protocol}#{domain}/#{namespace}/#{image_hash[0..2]}/#{image_hash[3..5]}/#{image_hash[6..8]}/#{image_hash[9..-1]}/#{size}"
      url += ".#{format}" unless size.to_s == 'original'
      url += '?processing' if processing
      url
    end

    def self.domain(image_hash)
      host = ImageServer.configuration.cdn_host
      sharded_cdn_template = ImageServer.configuration.sharded_cdn_host

      return host if image_hash.to_s.empty?
      return host unless sharded_cdn_template
      shard = image_hash[0].hex % ImageServer.configuration.sharded_host_count
      sharded_cdn_template % shard
    end
  end
end