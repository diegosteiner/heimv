class Booking
  class Filter < ApplicationFilter
    # attribute :begins_at
    attribute :begins_at, :datetime
    attribute :ends_at, :datetime
    attribute :ref
    attribute :tenant
    attribute :homes, default: []
    attribute :booking_states, default: []
    attribute :only_inconcluded, default: true

    filter :begins_at, :ends_at do |params, bookings|
      begins_at = params.fetch(:begins_at)
      ends_at = params.fetch(:ends_at)
      occupancy_booking_ids = Occupancy.at(begins_at..ends_at)
                                       .pluck(:booking_id)
      bookings.where(id: occupancy_booking_ids)
    end

    filter :ref do |params, bookings|
      bookings.where(Booking.arel_table[:ref].matches("%#{params[:ref]}%"))
    end

    filter :only_inconcluded do |params, bookings|
      params[:only_inconcluded] ? bookings.inconcluded : bookings
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

    def self.extract_time_from_param(param)
      return param if param.is_a?(DateTime)
    end
  end
end
