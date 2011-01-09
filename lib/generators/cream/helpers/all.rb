require_all File.dirname(__FILE__)

module Cream
  module GeneratorHelper
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