# frozen_string_literal: true

module Manage
  class OccupancyParams < ApplicationParamsSchema
    define do
      optional(:begins_at).filled(:date_time)
      optional(:ends_at).filled(:date_time)
      optional(:occupancy_type).maybe(:string)
      optional(:remarks).maybe(:string)
      optional(:color).maybe(:string)
      optional(:linked).maybe(:bool)
      optional(:occupiable_id).maybe(:integer)
      optional(:ignore_conflicting).filled(:bool)
    end
  end
end
