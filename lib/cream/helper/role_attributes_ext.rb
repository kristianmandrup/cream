# TODO
# Not finished! Very experimental
module Cream::Helper
  # as_role current_user_roles do |role| 
  #   role.update_attributes_of(Project).with params[:project] 
  #   role.create(Project).with params[:project] 
  # end
  def as_role role, &block
    yield RoleModelManager.new role
  end
  
  def as_roles *roles, &block
    yield RoleModelManager.new roles.flatten
  end

  class RoleModelManager
    attr_accessor :roles
  
    def initialize *roles
      @roles = roles.flatten
    end

    def update_attributes_of model_clazz
      AttributesUpdater.new model_clazz, roles
    end

    def create model_clazz
      ModelCreator.new model_clazz, roles
    end      
  
    class AttributesUpdater
      attr_accessor :clazz, :roles

      def initialize clazz, roles
        @clazz = clazz
        @roles = roles
      end
    
      def with attributes = {}
        clazz.constantize.update_attributes(attributes.merge(:as => roles.first))
      end
    end
  
    class ModelCreator
      attr_accessor :clazz, :roles

      def initialize clazz, roles
        @clazz = clazz
        @roles = roles        
      end
    
      def with attributes = {}
        clazz.constantize.create(attributes.merge(:as => roles.first))
      end
    end      
  end
end