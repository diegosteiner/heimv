class Booking
  class Filter < ApplicationFilter
    attribute :begins_at
    attribute :ends_at
    attribute :ref
    attribute :tenant
    attribute :homes, default: []
    attribute :booking_states, default: []

    filter :begins_at, :ends_at do |params, bookings|
      occupancy_booking_ids = Occupancy.at(params[:begins_at]..params[:ends_at])
                                       .pluck(:booking_id)
      bookings.where(id: occupancy_booking_ids)
    end

    filter :ref do |params, bookings|
      bookings.where(Booking.arel_table[:ref].matches("%#{params[:ref]}%"))
    end

    filter :homes do |params, bookings|
      homes = params[:homes].reject(&:blank?)
      next bookings if homes.blank?

      bookings.where(home_id: homes)
    end

    filter :tenant do |params, bookings|
      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{params[:tenant]}%")
          .or(Booking.arel_table[:organisation].matches("%#{params[:tenant]}%")))
    end

    filter :booking_states do |params, bookings|
      states = params[:booking_states].reject(&:blank?)
      next bookings if states.blank?

      bookings.where(state: states)
    end
  end
end
