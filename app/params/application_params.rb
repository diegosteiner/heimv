# frozen_string_literal: true

class ApplicationParams
  def self.permit(params)
    return if params.nil?
    sanitize(params).permit(permitted_keys)
  end

  def self.permitted_keys
    []
  end

  def self.sanitize(params)
    params
  end
end
