module ImageServer
  module ActiveRecord
    def image_server(column, namespace: 'img', versions: nil, processing_formats: [:jpg], default_size: 'full_size', default_format: 'jpg', sharded_cdn_template: nil)
      sizes   = versions.values.sort.uniq
      keys = versions.keys.sort.uniq
      processing_formats = processing_formats.map(&:to_s).sort.uniq
      outputs = sizes.flat_map { |s| processing_formats.map { |f| "#{s}.#{f}" } }
      outputs_str = outputs.join(',')

      namespace_constant = "#{column.to_s.upcase}_NAMESPACE"
      outputs_constant = "#{column.to_s.upcase}_OUTPUTS_STR"
      keys_constant = "#{column.to_s.upcase}_KEYS"

      sharded_cdn_template_constant = "#{column.to_s.upcase}_SHARDED_CDN_TEMPLATE"
      sharded_cdn_template = sharded_cdn_template ? "'#{sharded_cdn_template}'" : 'nil'

      class_eval <<-RUBY, __FILE__, __LINE__+1
        #{namespace_constant} = '#{namespace}'
        #{outputs_constant} = '#{outputs_str}'
        #{keys_constant} = #{keys}
        #{sharded_cdn_template_constant} = #{sharded_cdn_template}

        def remote_#{column}_url=(url)
          uploader = ImageServer::Uploader.new(#{namespace_constant}, url, #{outputs_constant})
          image_property = uploader.upload
          self.#{column}_hash = image_property.image_hash
        end

        def #{column}(options={})
          processing = #{column}_hash.blank?
          default_options = { protocol: #{column}_cdn_protocol,
                      domain: #{column}_cdn_domain,
                      default_size: '#{default_size}',
                      format: '#{default_format}',
                      processing: processing,
                      object: self }
          ImageServer::Image.new(#{namespace_constant}, #{column}_hash, default_options.merge(options))
        end

        def #{column}_url(*attrs)
          #{column}.url(*attrs).to_s
        end

        private

        def #{column}_cdn_protocol
          ImageServer.configuration.cdn_protocol
        end

        def #{column}_cdn_domain
          return #{column}_host if #{column}_hash.blank?
          return #{column}_host unless #{sharded_cdn_template_constant}
          shard = #{column}_hash[0].hex % #{column}_sharded_host_count
          #{sharded_cdn_template_constant} % shard
        end

        def #{column}_host
          ImageServer.configuration.cdn_host
        end

        def #{column}_sharded_host_count
          ImageServer.configuration.sharded_host_count
        end
      RUBY
    end
  end
end