# frozen_string_literal: true

module Public
  class AgentBookingSerializer < ApplicationSerializer
    fields :booking_agent_ref, :booking_agent_code

    field :links do |agent_booking|
      {
        edit: UrlService.instance.edit_public_agent_booking_url(agent_booking.to_param,
                                                                org: agent_booking.organisation.slug)
      }
    end
  end
end
