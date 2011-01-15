module Cream
  module Rails
    class Config      
      attr_accessor :roles, :user_types
      
      def initialize options = {}
        self.roles ||= options[:roles] 
        self.user_types ||= options[:user_types] 
      end
    end
  end
end