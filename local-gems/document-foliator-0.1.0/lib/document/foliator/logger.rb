require "logger"

module Document
  module Foliator
    module_function

    LOG_FILENAME = "/tmp/foliator.log"

    def logger
      Logger.new(LOG_FILENAME, 10, 1024000)
    end
  end
end
