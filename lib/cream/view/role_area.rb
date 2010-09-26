require 'sugar-high/arguments'

module Cream::View
  module Role
    # for users WITH the given roles create a div area
    # with optional class given in options hash and render block
    # within this div  
    def area_for_roles(*user_roles, &block)
      options = last_option(user_roles)

      return area(&block) if user_roles.empty?
      
      not_for_roles(user_roles, &block) if user_roles.first == false
      
      for_roles user_roles do
        area(options, &block)
      end
    end   
    alias_method :area_for_role, :area_for_roles

    # for users WITHOUT the given roles create a div area
    # with optional class given in options hash and render block
    # within this div  
    def area_not_for_roles(*user_roles, &block)
      options = last_option(user_roles)
      not_for_roles user_roles do             
        clazz = options[:class] || 'special'
        area(:class => clazz, &block)
      end
    end  
    alias_method :area_not_for_role, :area_not_for_roles
    
    def area(options=nil, &block)
      content = yield #with_output_buffer(&block)
      content_tag :div, content, options
    end    
  end
end