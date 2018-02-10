module Public
  class BaseController < ApplicationController
    def current_ability
      @current_ability ||= Ability::Public.new(current_user)
    end
  end
end
