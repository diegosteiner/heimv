module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancy,home'.freeze

    has_one :occupancy, serializer: Public::OccupancySerializer
    has_one :home, serializer: Public::HomeSerializer
    has_one :organisation, serializer: Public::OrganisationSerializer
    has_one :agent_booking, serializer: Public::AgentBookingSerializer

    attribute :links do
      { edit: edit_public_booking_url(object.to_param, host: object.organisation.host) }
    end
  end
end
