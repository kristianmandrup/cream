module Cream::View
  module Role    
    # admin?,  guest? ...
    Cream::Role.available.each do |role|
      class_eval %{
        def #{role}_area &block
          area_for_roles(#{role}, &block)
        end 
        
        def for_#{role}(&block)
          for_roles(#{role}, &block)          
        end
      }
    end
  end
end

module Cream::Helper
  module Role    
    # admin?,  guest? ...
    Cream::Role.available.each do |role|
      class_eval %{
        def #{role}?
          has_role? :#{role}
        end
      }
    end
  end
end