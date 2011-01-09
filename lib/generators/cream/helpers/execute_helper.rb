module Cream
  module GeneratorHelper
    module Executor
      # rails generate ...
      def rgen command
        execute "rails g #{command}"
      end        

      def execute command
        logger.debug command
        run command
      end

      def bundle_install
        run "bundle install"
      end
    end
  end
end