# frozen_string_literal: true

class ApplicationParams
  class << self

  def nested(nested_params_hash)
    @nested_params ||= {}
    @nested_params.merge!(nested_params_hash)
  end

  def permit_nested(params)
    return params if @nested_params.blank?

    @nested_params.inject(params) do |params2, (key, params_klass)|
    raise "y"
      x = params2.delete(key)
      next params2 unless x && params_klass.respond_to?(:permit)

      params2[key] = params_klass.permit(x)
      params2
    end
  end

  def permit(params)
    return default unless params.present?

    permit_nested(params).permit(permitted_keys)
  end

  def default
    ActionController::Parameters.new
  end

  def permitted_keys
    []
  end
  end
end
