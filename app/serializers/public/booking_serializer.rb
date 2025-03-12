# frozen_string_literal: true

module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancies,occupancies.home,organisation,agent_booking,deadlines,tenant'

    association :home, blueprint: Public::HomeSerializer
    association :occupancies,   blueprint: Public::OccupancySerializer
    association :organisation,  blueprint: Public::OrganisationSerializer
    association :agent_booking, blueprint: Public::AgentBookingSerializer

    fields :begins_at, :ends_at, :occupancy_type, :nights, :occupancy_color, :home_id, :occupiable_ids
    field :deadline do |booking|
      booking.deadline&.at
    end

    field :links do |booking|
      next { edit: nil } if booking.new_record?

      { edit: edit_public_booking_url(booking.token || booking.to_param, org: booking.organisation,
                                                                         locale: I18n.locale) }
    end
  end
end
