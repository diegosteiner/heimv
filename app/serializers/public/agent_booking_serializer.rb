# frozen_string_literal: true

module Public
  class AgentBookingSerializer < ApplicationSerializer
    identifier :id
    fields :booking_agent_ref, :booking_agent_id
    # association :booking_agent, blueprint: Public::AgentBookingSerializer

    field :booking_agent_name do |agent_booking|
      agent_booking&.booking_agent&.name
    end

    field :links do |agent_booking|
      {
        edit: edit_public_agent_booking_url(agent_booking.token || agent_booking.to_param,
                                            org: agent_booking.organisation, locale: I18n.locale),
        show: edit_public_agent_booking_url(agent_booking.token, org: agent_booking.organisation, locale: I18n.locale)
      }
    end
  end
end
