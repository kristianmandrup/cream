# Not yet used! Should use it?

module Cream
  # Include helpers in the given scope to AC and AV.
  # "Borrowed" from devise
  def self.include_helpers(scope)
    ActiveSupport.on_load(:action_controller) do
      include scope::Helpers
      include scope::UrlHelpers
    end

    ActiveSupport.on_load(:action_view) do
      include scope::UrlHelpers
    end
  end

  class Engine < ::Rails::Engine
    initializer "cream.helpers" do
      Cream.include_helpers(Cream::Controllers)
    end    
  end
end
