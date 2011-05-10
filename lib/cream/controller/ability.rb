module Cream::Controller
  module Ability
    def current_ability
      @current_ability ||= Permits::Ability.new(role_subject, request)
    end
  end
end

