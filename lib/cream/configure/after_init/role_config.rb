module Cream::View
  module Role
    def self.roles_available
      begin
        return Cream::Role.available if defined? Cream::Role
      rescue
      end
      [:guest, :admin]
    end
        
    # admin?,  guest? ...
    Cream::View::Role.roles_available.each do |role|
      class_eval %{
        def #{role}_area &block
          area_for_role(:#{role}, &block)
        end 
      
        def for_#{role}(&block)
          for_role(:#{role}, &block)          
        end
      }
    end
  end
end

module Cream::Helper
  module Role    
    # admin?,  guest? ...
    Cream::View::Role.roles_available.each do |role|
      class_eval %{
        def #{role}?
          has_role? :#{role}
        end
      }
    end
  end
end