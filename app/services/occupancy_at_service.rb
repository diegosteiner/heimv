# frozen_string_literal: true

class OccupancyAtService
  include Rails.application.routes.url_helpers

  def initialize(occupiable, occupancies)
    @occupiable = occupiable
    @occupancies = occupancies
  end

  def redirect_to(date, manage: false)
    defaults = { org: @occupiable.organisation, locale: I18n.locale }

    if date && manage
      occupancies = at(date)
      bookings = occupancies.filter_map(&:booking)
      return manage_booking_path(bookings.first, **defaults)               if bookings.one?
      return edit_manage_occupancy_path(id: occupancies.first, **defaults) if occupancies.one?

      return manage_bookings_path(filter: booking_filter_params(date), **defaults)
    end

    new_public_booking_path(booking: { occupiable_ids: [@occupiable.id], begins_at: date }, **defaults)
  end

  def at(date)
    return Occupancy.none if date.blank?

    Occupancy::Filter.new(begins_at_before: date.end_of_day, ends_at_after: date.beginning_of_day,
                          occupancy_type: %i[tentative occupied closed]).apply(@occupancies)
  end

  def booking_filter_params(date)
    return unless date

    {
      occupiables: [@occupiable.id], current_booking_states: [nil],
      at_date: date, occupancy_type: %i[tentative occupied]
    }
  end
end
