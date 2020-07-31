module Public
  class AgentBookingSerializer < ApplicationSerializer
    # has_one :booking_agent, serializer: Public::OccupancySerializer

    attributes :booking_agent_ref, :booking_agent_code

    attribute :links do
      { edit: edit_public_agent_booking_url(object.to_param, host: object.organisation.host) }
    end
  end
end
