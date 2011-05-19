module Cream::Helper
  module LanguageExt 
    def set_language language_code
     current_user.language_code = language_code if user_has_language_code?
     guest_options[:language_code] = language_code # for guest user
    end

    private

    def user_has_language_code?
      the_current_user && the_current_user.respond_to?(:language_code) # for non-guest user
    end
  end
end