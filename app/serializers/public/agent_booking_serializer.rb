# frozen_string_literal: true

module Public
  class AgentBookingSerializer < ApplicationSerializer
    fields :booking_agent_ref, :booking_agent_id
    # association :booking_agent, blueprint: Public::AgentBookingSerializer

    field :booking_agent_name do |agent_booking|
      agent_booking&.booking_agent&.name
    end

    field :links do |agent_booking|
      {
        edit: url.edit_public_agent_booking_url(agent_booking.token || agent_booking.to_param,
                                                org: agent_booking.organisation)
      }
    end
  end
end
