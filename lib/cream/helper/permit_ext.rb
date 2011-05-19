module Cream::Helper
  module PermitExt
    def user_can? action, obj, &block
      (block ? yield : true) if current_ability.can? action, obj
    end

    def user_cannot? action, obj, &block
      (block ? yield : true) if !current_ability.can? action, obj
    end

    def user_owns? obj, relation = nil, &block
      (block ? yield : true)  if !current_ability.owns(obj, relation)
    end
  end
end