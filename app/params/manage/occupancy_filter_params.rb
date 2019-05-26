# frozen_string_literal: true

module Manage
  class OccupancyFilterParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at_before begins_at_after ends_at_before ends_at_after]
    end

    def self.sanitize(params)
      params ||= ActionController::Parameters.new
      params.merge(
        begins_at_after: extract_datetime_from_params(params, :begins_at_after),
        begins_at_before: extract_datetime_from_params(params, :begins_at_before),
        ends_at_after: extract_datetime_from_params(params, :ends_at_after),
        ends_at_before: extract_datetime_from_params(params, :ends_at_before)
      )
    end

    def self.extract_datetime_from_param_groups(params, composit_key)
      return if params.blank?

      keys = params.keys.select { |key| key.to_s.starts_with?(composit_key.to_s) }.sort
      datetime_array = keys.map { |key| params.delete(key).to_i }
      datetime_array[0..2].all?(&:positive?) ? Time.zone.local(*datetime_array) : nil
      # raise "o"
    end
  end
end
