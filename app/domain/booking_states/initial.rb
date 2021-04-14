# frozen_string_literal: true

module BookingStates
  class Initial < Base
    def self.to_sym
      :initial
    end

    infer_transition(to: :open_request, &:agent_booking?)
    infer_transition(to: :unconfirmed_request) do |booking|
      booking.email.present? && !booking.agent_booking?
    end

    def self.hidden
      true
    end
  end
end
