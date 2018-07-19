# frozen_string_literal: true

class ApplicationParams
  def self.permit(params)
    return if params.nil?
    Rails.logger.debug(['Params [raw]: ', params])
    params = sanitize(params).permit(permitted_keys)
    Rails.logger.debug(['Params [permitted]: ', params])
    params
  end

  def self.permitted_keys
    []
  end

  def self.sanitize(params)
    params
  end
end
