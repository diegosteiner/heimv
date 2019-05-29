# frozen_string_literal: true

class ApplicationParams
  class << self
    def permit(params)
      params&.permit(permitted_keys) || default.permit
    end

    def default
      ActionController::Parameters.new
    end

    def permitted_keys
      []
    end
  end
end
