module Cream::Controller
  module Ability
    def current_ability
      @current_ability ||= Permits::Ability.new(current_user, request)
    end
  end
end

