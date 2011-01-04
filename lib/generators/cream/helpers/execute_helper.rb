module Cream
  module GeneratorHelper
    module Executor
      def add_gem name
        gem name if !has_gem? name
      end      
       
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