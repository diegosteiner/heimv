# frozen_string_literal: true

class Booking
  class Filter < ApplicationFilter
    attribute :ref
    attribute :tenant
    attribute :categories
    attribute :homes, default: -> { [] }
    attribute :current_booking_states, default: -> { [] }
    attribute :previous_booking_states, default: -> { [] }
    attribute :booking_states, default: -> { [] }
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :occupancy_type

    def occupancy_filter
      @occupancy_filter ||= Occupancy::Filter.new({ begins_at_before: begins_at_before,
                                                    begins_at_after: begins_at_after,
                                                    ends_at_before: ends_at_before,
                                                    ends_at_after: ends_at_after })
    end

    filter :occupancy do |bookings|
      bookings.where(occupancy: occupancy_filter.apply(Occupancy.where.not(booking: nil)))
    end

    filter :occupancy_type do |bookings|
      bookings.joins(:occupancy).merge(Occupancy.where(occupancy_type: occupancy_type)) if occupancy_type.present?
    end

    filter :ref do |bookings|
      bookings.where(Booking.arel_table[:ref].matches("%#{ref.strip}%")) if ref.present?
    end

    filter :homes do |bookings|
      relevant_homes = Array.wrap(homes).compact_blank
      bookings.where(home_id: relevant_homes) if relevant_homes.present?
    end

    filter :categories do |bookings|
      categories = Array.wrap(categories).compact_blank
      next if categories.blank?

      category_ids = BookingCategory.where(key: categories).pluck(:id) + categories
      bookings.where(booking_category_id: category_ids)
    end

    filter :tenant do |bookings|
      next bookings if tenant.blank?

      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches("%#{tenant}%")
          .or(Booking.arel_table[:tenant_organisation].matches("%#{tenant}%")))
    end

    filter :has_booking_state do |bookings|
      states = Array.wrap(current_booking_states).compact_blank

      bookings.where(booking_state_cache: states) if states.any?
    end

    filter :had_booking_state do |bookings|
      states = Array.wrap(previous_booking_states).compact_blank

      bookings.joins(:state_transitions).where(state_transitions: { to_state: states }) if states.any?
    end
  end
end
