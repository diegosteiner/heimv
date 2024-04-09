# frozen_string_literal: true

module Manage
  class BookingFilterParams < ApplicationParamsSchema
    define do
      optional(:q).maybe(:string)
      optional(:begins_at_before).maybe(:date_time)
      optional(:begins_at_after).maybe(:date_time)
      optional(:ends_at_before).maybe(:date_time)
      optional(:ends_at_after).maybe(:date_time)
      optional(:at_date).maybe(:date)
      optional(:concluded).maybe(:string)

      optional(:current_booking_states).array(:string)
      optional(:previous_booking_states).array(:string)
      optional(:homes).array(:integer)
      optional(:occupiables).array(:integer)
    end
  end
end
