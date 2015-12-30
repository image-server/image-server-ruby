require 'uri'

module ImageServer
  class Configuration
    attr_accessor :logger
    attr_accessor :log_directory
    attr_writer   :upload_host
    attr_accessor :cdn_protocol
    attr_accessor :cdn_host
    attr_accessor :sharded_cdn_host
    attr_accessor :sharded_host_count

    def port
      return unless @upload_host

      URI(upload_host).port
    end

    # returns upload_host with a protocol included
    # example: if @upload_host is `example.com` will return `http://example.com`
    def upload_host
      return unless @upload_host
      return @upload_host if @upload_host.start_with?('http')

      "http://#{@upload_host}"
    end
  end
end