class Booking
  class Filter < ApplicationFilter
    attribute :ref
    attribute :tenant
    attribute :homes, default: []
    attribute :occupancy_params, default: {}
    attribute :current_booking_states, default: []
    attribute :previous_booking_states, default: []
    attribute :booking_states, default: []

    def booking_states=(value)
      self.current_booking_states = value
    end

    def occupancy
      @occupancy ||= Occupancy::Filter.new(occupancy_params)
    end

    filter :occupancy do |bookings|
      bookings.where(occupancy: occupancy.apply(Occupancy.unscoped))
    end

    filter :ref do |bookings|
      next bookings if ref.blank?

      bookings.where(Booking.arel_table[:ref].matches("%#{ref}%"))
    end

    filter :homes do |bookings|
      relevant_homes = homes.reject(&:blank?)
      next bookings if relevant_homes.blank?

      bookings.where(home_id: relevant_homes)
    end

    filter :tenant do |bookings|
      next bookings if tenant.blank?

      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{tenant}%")
          .or(Booking.arel_table[:tenant_organisation].matches("%#{tenant}%")))
    end

    filter :has_booking_state do |bookings|
      states = current_booking_states.reject(&:blank?)

      bookings.where(state: states) if states.any?
    end

    filter :had_booking_state do |bookings|
      states = previous_booking_states.reject(&:blank?)

      bookings.joins(:booking_transitions).where(booking_transitions: { to_state: states }) if states.any?
    end
  end
end
