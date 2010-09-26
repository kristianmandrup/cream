module Cream
  module Rails
    class Config      
      attr_accessor :roles
      
      def initialize options = {}
        self.roles ||= options[:roles] 
      end
    end
  end
end