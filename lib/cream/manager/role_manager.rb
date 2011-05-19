module Cream
  class RoleModelManager
    attr_accessor :roles
  
    def initialize *roles
      @roles = roles.flatten
    end

    def update_attributes_of model_clazz
      AttributesUpdater.new model_clazz
    end

    def create model_clazz
      ModelCreator.new model_clazz
    end      
  
    class AttributesUpdater
      attr_accessor :clazz

      def initialize clazz
        @clazz = clazz
      end
    
      def with attributes = {}
        clazz.constantize.update_attributes(attributes.merge(:as => roles))
      end
    end
  
    class ModelCreator
      attr_accessor :clazz

      def initialize clazz
        @clazz = clazz
      end
    
      def with attributes = {}
        clazz.constantize.create(attributes.merge(:as => roles))
      end
    end      
  end
end