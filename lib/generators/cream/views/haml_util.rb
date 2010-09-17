module Cream
  module Generators
    module HamlUtil
      def verify_haml_existence
        begin
          require 'haml'
        rescue LoadError
          say "HAML is not installed, or it is not specified in your Gemfile."
          exit
        end
      end

      def verify_haml_version
        unless Haml.version[:major] == 2 and Haml.version[:minor] >= 3 or Haml.version[:major] >= 3
          say "To generate HAML templates, you need to install HAML 2.3 or above."
          exit
        end
      end

      def create_and_copy_haml_views
        verify_haml_existence
        verify_haml_version
  
        require 'tmpdir'
        html_root = "#{self.class.source_root}/cream"

        Dir.mktmpdir("cream-haml.") do |haml_root|
          Dir["#{html_root}/**/*"].each do |path|
            relative_path = path.sub(html_root, "")
            source_path   = (haml_root + relative_path).sub(/erb$/, "haml")

            if File.directory?(path)
              FileUtils.mkdir_p(source_path)
            else
              `html2haml -r #{path} #{source_path}`
            end
          end

          directory haml_root, "app/views/#{scope || 'devise'}"
        end
      end
    end
  end
end