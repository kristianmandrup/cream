module Cream::View
  module UserActionMenu       

    MENU_ITEMS = {
      :sign_out => :logout, 
      :sign_in => :login, 
      :sign_up => :register,
      :edit_registration => [:edit_user, :edit_account]
    }

    MENU_ITEMS.keys.each do |name|
      class_eval %{
        def #{name}_menu_item tag = 'li'
          content_tag tag, #{name}_link
        end          
      }      
    end
  
    multi_alias :menu_item, MENU_ITEMS
  end  
end
