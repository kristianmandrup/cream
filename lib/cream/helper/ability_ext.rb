module Cream::Helper
  module AbilityExt
    def current_ability           
      current_ability_of role_subject
    end

    def current_ability_of subject
      Permits::Ability.new(subject, request)
    end
  end
end

