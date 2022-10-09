# frozen_string_literal: true

class OccupancyAtService
  include Rails.application.routes.url_helpers

  def initialize(home, occupancies)
    @home = home
    @occupancies = occupancies
  end

  def redirect_to(date, manage: false)
    org = @home.organisation

    if date && manage
      occupancies = at(date)
      bookings = occupancies.filter_map(&:booking)
      return manage_bookings_path(booking_filter_params(date).merge(org: org)) if bookings.count > 1
      return manage_booking_path(bookings.first, org: org)                     if bookings.count == 1
      return edit_manage_occupancy_path(id: occupancies.first, org: org)       if occupancies.count == 1
    end

    new_public_booking_path(org: org, booking: { home_id: @home.to_param, occupancy_attributes: { begins_at: date } })
  end

  def at(date)
    return Occupancy.none if date.blank?

    Occupancy::Filter.new(begins_at_before: date.end_of_day, ends_at_after: date.beginning_of_day).apply(@occupancies)
  end

  def booking_filter_params(date)
    return unless date

    {
      homes: [@home.id], current_booking_states: [nil],
      begins_at_before: date.end_of_day, ends_at_after: date.beginning_of_day,
      occupancy_type: %i[tentative occupied]
    }
  end
end