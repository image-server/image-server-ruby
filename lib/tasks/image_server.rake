namespace :image_server do
  desc 'Installs the image server if not available'
  task :install => :environment do
    require 'image_server/installer'

    ImageServer::Installer.install
  end
end