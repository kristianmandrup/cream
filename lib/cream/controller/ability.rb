module Cream::Controller
  module Ability
    def current_ability
      @current_ability ||= Ability.new(current_user, request)
    end
  end
end