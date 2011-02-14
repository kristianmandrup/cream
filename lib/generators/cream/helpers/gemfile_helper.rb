module Cream
  module GeneratorHelper
    module Gemfile 
      def add_gem_version name, version
        if !has_gem? name
          debug! "Adding gem: #{name}, #{version}"
          gem name, :version => version
        else
          debug! "gem: #{name}, #{version} already in Gemfile"
        end        
      end

      def add_gem name, version = nil
        if version
          add_gem_version name, version 
          return 
        end

        if !has_gem? name
          debug! "Adding gem: #{name}"
          gem name
        else
          debug! "gem: #{name} already in Gemfile"          
        end
      end
    end
  end
end