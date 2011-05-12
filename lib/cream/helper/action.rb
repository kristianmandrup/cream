# TODO
# should use #role_subject instead!
# #current_ability is available to make cancan tests like user_can? and user_cannot?

module Cream::Helper
  module Action
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