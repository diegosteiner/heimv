# frozen_string_literal: true

module Public
  class AgentBookingParams < ApplicationParams
    def self.permitted_keys
      [:booking_agent_code, :email, :booking_agent_ref, booking_attributes: BookingParams::Create.permitted_keys]
    end

    sanitize do |params|
      params.merge(booking_attributes: BookingParams::Create.new(params[:booking_attributes]).permitted)
    end
  end
end
