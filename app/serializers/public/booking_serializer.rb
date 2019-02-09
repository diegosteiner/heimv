module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancy,home'.freeze

    has_one :occupancy, serializer: Public::OccupancySerializer
    has_one :home, serializer: Public::HomeSerializer

    link(:edit) { edit_public_booking_url(object.to_param) }
  end
end
