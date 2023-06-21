# frozen_string_literal: true

module Manage
  class BookingFilterParams < ApplicationParams
    def self.permitted_keys
      %i[tenant ref begins_at_before begins_at_after ends_at_before ends_at_after at_date] +
        [current_booking_states: [], previous_booking_states: [], homes: [], occupiables: []]
    end
  end
end
