# frozen_string_literal: true

module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancies'

    association :homes,         blueprint: Public::HomeSerializer
    # association :occupancies,   blueprint: Public::OccupancySerializer
    association :organisation,  blueprint: Public::OrganisationSerializer
    association :agent_booking, blueprint: Public::AgentBookingSerializer

    field :deadline do |booking|
      booking.deadline&.at
    end

    field :links do |booking|
      next { edit: nil } if booking.new_record?

      { edit: url.edit_public_booking_url(booking.token || booking.to_param, org: booking.organisation) }
    end
  end
end
