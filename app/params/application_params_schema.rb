# frozen_string_literal: true

class ApplicationParamsSchema < Dry::Schema::Params
  def self.permit(params)
    new.call(params.try(:to_unsafe_hash) || params).to_h
  end
end
