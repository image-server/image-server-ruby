$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'

require 'image_server'

ImageServer.configure do |config|
  config.upload_host = '127.0.0.1:7000'
end