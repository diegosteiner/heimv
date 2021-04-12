# frozen_string_literal: true

module BookingStates
  class Completed < BookingState
    def checklist
      []
    end

    def self.to_sym
      :completed
    end

    guard_transition do |booking|
      !booking.invoices.unpaid.exists?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.concluded!
    end

    def relevant_time; end
  end
end
