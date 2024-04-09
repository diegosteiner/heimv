# frozen_string_literal: true

module Manage
  class OccupancyFilterParams < ApplicationParamsSchema
    define do
      optional(:begins_at_before).maybe(:date_time)
      optional(:begins_at_after).maybe(:date_time)
      optional(:ends_at_before).maybe(:date_time)
      optional(:ends_at_after).maybe(:date_time)
    end
  end
end
