module ImageServer
  class Configuration
    attr_accessor :logger
    attr_accessor :upload_host
    attr_accessor :cdn_protocol
    attr_accessor :cdn_host
    attr_accessor :sharded_host_count
  end
end