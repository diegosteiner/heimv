# frozen_string_literal: true

class BookingAtService
  include Rails.application.routes.url_helpers

  def initialize(home, bookings)
    @home = home
    @bookings = bookings
  end

  def at(date, manage: false)
    bookings = bookings_of_date(date)
    org = @home.organisation.slug

    return manage_bookings_path(filter_params.merge(org: org)) if manage && bookings.count > 1
    return manage_booking_path(bookings.first, org: org)       if manage && bookings.count == 1

    new_public_booking_path(org: org, booking: { home_id: @home.to_param, occupancy_attributes: { begins_at: date } })
  end

  def bookings_of_date(date)
    return [] if date.blank?

    filter_params = {
      homes: [@home.id],
      begins_at_before: date.end_of_day, ends_at_after: date.beginning_of_day,
      occupancy_type: %i[tentative occupied]
    }
    Booking::Filter.new(filter_params).apply(@bookings)
  end
end
