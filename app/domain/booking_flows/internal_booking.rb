# frozen_string_literal: true

module BookingFlows
  class InternalBooking < Base
    state :initial, BookingStates::Initial, to: %i[open_request], initial: true
    state :open_request, BookingStates::OpenRequest, to: %i[upcoming]
    state :upcoming, BookingStates::Upcoming, to: %i[upcoming_soon]
    state :upcoming_soon, BookingStates::UpcomingSoon, to: %i[active]
    state :active, BookingStates::Active, to: %i[completed]
    state :completed, BookingStates::Completed

    def self.displayed_by_default
      @displayed_by_default ||= %i[open_request upcoming upcoming_soon active]
    end

    def self.occupied_by_default
      @occupied_by_default ||= %i[upcoming upcoming_soon active]
    end

    def self.editable_by_default
      @editable_by_default ||= %i[initial open_request]
    end

    def self.manage_actions
      {}
    end

    def self.tenant_actions
      {}
    end

    def self.booking_agent_actions
      {}
    end
  end
end
