# frozen_string_literal: true

module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancy,home'

    association :occupancy,     blueprint: Public::OccupancySerializer
    association :home,          blueprint: Public::HomeSerializer
    association :organisation,  blueprint: Public::OrganisationSerializer
    association :agent_booking, blueprint: Public::AgentBookingSerializer

    field :deadline do |occupancy|
      booking.deadline&.at
    end

    field :links do |booking|
      { edit: url.edit_public_booking_url(booking.to_param, org: booking.organisation.slug) }
    end
  end
end
