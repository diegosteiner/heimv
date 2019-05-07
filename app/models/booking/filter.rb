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

    filter do |bookings|
      bookings.where(occupancy: occupancy.reduce(Occupancy.unscoped))
    end

    filter do |bookings|
      next bookings if ref.blank?

      bookings.where(Booking.arel_table[:ref].matches("%#{f.ref}%"))
    end

    filter do |bookings|
      only_inconcluded ? bookings.inconcluded : bookings
    end

    filter do |bookings|
      relevant_homes = homes.reject(&:blank?)
      next bookings if relevant_homes.blank?

      bookings.where(home_id: relevant_homes)
    end

    filter do |bookings|
      next bookings if tenant.blank?

      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{f.tenant}%")
          .or(Booking.arel_table[:tenant_organisation].matches("%#{f.tenant}%")))
    end

    filter do |bookings|
      states = booking_states.reject(&:blank?)
      next bookings if states.blank?

      bookings.where(state: states)
    end
  end
end
