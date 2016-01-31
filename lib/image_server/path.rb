module ImageServer
  class Path
    def self.directory_path(namespace, image_hash)
      "#{namespace}/#{image_hash[0..2]}/#{image_hash[3..5]}/#{image_hash[6..8]}/#{image_hash[9..-1]}"
    end
  end
end