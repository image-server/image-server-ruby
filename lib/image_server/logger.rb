require 'logger'

module ImageServer
  class Logger
    LOG_PREFIX = '** [ImageServer]'

    [
      :fatal,
      :error,
      :warn,
      :info,
      :debug,
    ].each do |level|
      define_method level do |*args, &block|
        msg = block.call if block
        logger = ImageServer.configuration.logger
        logger ||= ::Logger.new(STDOUT)

        logger.send(level, "#{LOG_PREFIX} #{msg}") if logger
      end
    end
  end
end
