# frozen_string_literal: true

module BookingStates
  class Completed < Base
    def checklist
      []
    end

    def self.to_sym
      :completed
    end

    def self.hidden
      true
    end

    guard_transition do |booking|
      !booking.invoices.unpaid.exists?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.conclude
    end

    def relevant_time; end
  end
end
