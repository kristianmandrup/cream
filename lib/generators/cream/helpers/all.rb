require 'generators/cream/core_ext'
require_all File.dirname(__FILE__)

module Cream
  module GeneratorHelper
    def logit!  
      if logging?
        add_logger
        logger.add_logfile :logfile => logfile
      end
    end

    def add_logger
      require 'logging_assist'
      class_eval do
        send :include, RailsAssist::BasicLogger
      end
    end

    def debug! msg
      logger.debug msg if logging?
    end

    def info! msg
      logger.info msg if logging?
    end
    
    def self.included(base)
      base.class_eval do
        include Orm
        include Executor
        include Args
        include Strategy
        include Gemfile
      end
    end
  end
end