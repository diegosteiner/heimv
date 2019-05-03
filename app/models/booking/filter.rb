class Booking
  class Filter < ApplicationFilter
    attribute :ref
    attribute :tenant
    attribute :homes, default: []
    attribute :occupancy_params, default: {}
    attribute :booking_states, default: []
    attribute :only_inconcluded, default: true

    def occupancy
      @occupancy ||= Occupancy::Filter.new(occupancy_params)
    end

    filter do |bookings, f|
      bookings.where(occupancy: f.occupancy.reduce(Occupancy.unscoped))
    end

    filter do |bookings, f|
      next bookings if f.ref.blank?

      bookings.where(Booking.arel_table[:ref].matches("%#{f.ref}%"))
    end

    filter do |bookings, f|
      f.only_inconcluded ? bookings.inconcluded : bookings
    end

    filter do |bookings, f|
      homes = f.homes.reject(&:blank?)
      next bookings if homes.blank?

      bookings.where(home_id: homes)
    end

    filter do |bookings, f|
      next bookings if f.tenant.blank?

      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{f.tenant}%")
          .or(Booking.arel_table[:tenant_organisation].matches("%#{f.tenant}%")))
    end

    filter do |bookings, f|
      states = f.booking_states.reject(&:blank?)
      next bookings if states.blank?

      bookings.where(state: states)
    end
  end
end
