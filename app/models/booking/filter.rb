class Booking
  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :ref
    attribute :tenant
    attribute :homes, default: []
    attribute :booking_states, default: []
    attribute :only_inconcluded, default: true

    filter do |bookings, **params|
      occupancies = Occupancy.where.not(booking: nil)
                             .begins_at(after: params[:begins_at_after], before: params[:begins_at_before])
                             .ends_at(after: params[:ends_at_after], before: params[:ends_at_before])
      bookings.where(occupancy: occupancies)
    end

    filter do |bookings, ref: nil, **_params|
      next bookings if ref.blank?

      bookings.where(Booking.arel_table[:ref].matches("%#{ref}%"))
    end

    filter do |bookings, only_inconcluded: nil, **_params|
      next bookings if only_inconcluded.blank?

      only_inconcluded ? bookings.inconcluded : bookings
    end

    filter do |bookings, homes: [], **_params|
      homes = homes.reject(&:blank?)
      next bookings if homes.blank?

      bookings.where(home_id: homes)
    end

    filter do |bookings, tenant: nil, **_params|
      next bookings if tenant.blank?

      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{tenant}%")
          .or(Booking.arel_table[:tenant_organisation].matches("%#{tenant}%")))
    end

    filter do |bookings, booking_states: [], **_params|
      states = booking_states.reject(&:blank?)
      next bookings if states.blank?

      bookings.where(state: states)
    end
  end
end
