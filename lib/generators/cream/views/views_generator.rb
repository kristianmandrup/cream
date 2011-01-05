require 'sugar-high/path'
require 'generators/cream/views/haml_util'

module Cream
  module Generators
    class ViewsGenerator < ::Rails::Generators::Base
      desc "Copies all Cream views to your application."
      
      argument      :scope, :required => false, :default => nil, :desc => "The scope to copy views to"
      
      class_option  :haml, :type => :boolean, :default => "erb", :desc => "Use HAML"
      
      def self.source_root
        @_devise_source_root ||= File.expand_path("app/views".path.up(5), __FILE__)
      end
          
      def copy_views
        if options[:haml]
          create_and_copy_haml_views
        else
          copy_erb_views
        end
      end
      
      protected
    
      def copy_erb_views
        directory "cream", "app/views/#{scope || 'cream'}"        
      end
      
      include Cream::Generators::HamlUtil
    end
  end
end