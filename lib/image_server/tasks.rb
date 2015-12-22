spec = Gem::Specification.find_by_name 'image-server'
load "#{spec.gem_dir}/lib/tasks/image_server.rake"