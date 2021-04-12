# frozen_string_literal: true

module BookingStates
  class Initial < BookingState
    def self.to_sym
      :initial
    end

    infer_transition(to: :open_request, &:agent_booking?)
    infer_transition(to: :unconfirmed_request) do |booking|
      booking.email.present? && !booking.agent_booking?
    end

    def self.successors
      %i[unconfirmed_request provisional_request definitive_request open_request upcoming]
    end
  end
end
