module Cream::Helper
  module AuthLabel          
    def auth_labels
      @auth_labels ||= translate_labels
    end

    protected

    def translate_labels
      ns_actions = 'cream.actions'
      labels = {}
      %w{new edit delete show sign_in sign_out sign_up edit_registration}.each do |action|     
        labels[action.to_sym] = t "#{ns_actions}.#{action}"
      end 
      labels[:confirm] = t 'cream.confirm'
      labels           
    end    
  end
end
