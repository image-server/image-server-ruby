namespace :image_server do
  desc 'Installs the image server if not available'
  task :install do
    ImageServer::Installer.new.install
  end
end