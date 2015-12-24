namespace :image_server do
  desc 'Installs the image server if not available'
  task :install do
    require 'net/http'
    require 'uri'
    require 'open-uri'
    require 'fileutils'

    class ImageServerHelper
      def valid_platform?
        %(darwin linux).include?(platform)
      end

      def platform
        `uname -s`.strip.downcase
      end

      def current_version
        '1.15.0'
      end

      def executable_name
        "images-#{platform}-#{current_version}"
      end

      def remote_url
        "https://github.com/image-server/image-server/releases/download/v#{current_version}/#{executable_name}"
      end

      def installed_latest?
        File.exist?('bin/images') && `bin/image --version`.split(' ').last.chomp == current_version
      rescue
        false
      end
    end

    helper = ImageServerHelper.new
    next unless helper.valid_platform?
    next if helper.installed_latest?

    FileUtils.mkdir_p 'bin'
    File.open('bin/images', 'wb') do |saved_file|
      open(helper.remote_url, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
    end
    File.chmod(744, 'bin/images')
  end
end