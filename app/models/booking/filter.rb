# frozen_string_literal: true

class Booking
  class Filter < ApplicationFilter
    attribute :q
    attribute :categories
    attribute :homes, default: -> { [] }
    attribute :occupiables, default: -> { [] }
    attribute :current_booking_states, default: -> { [] }
    attribute :previous_booking_states, default: -> { [] }
    attribute :booking_states, default: -> { [] }
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :at_date, :date
    attribute :occupancy_type
    attribute :concluded

    filter :at_date do |bookings|
      next if at_date.blank?

      bookings.at(from: at_date.beginning_of_day, to: at_date.end_of_day)
    end

    filter :begins_at_ends_at do |bookings|
      bookings.begins_at(after: begins_at_after, before: begins_at_before)
              .ends_at(after: ends_at_after, before: ends_at_before)
    end

    filter :occupancy_type do |bookings|
      bookings.where(occupancy_type:) if occupancy_type.present?
    end

    filter :homes do |bookings|
      relevant_homes = Array.wrap(homes).compact_blank
      bookings.joins(:occupancies).where(home_id: relevant_homes) if relevant_homes.present?
    end

    filter :occupiables do |bookings|
      relevant_occupiables = Array.wrap(occupiables).compact_blank
      if relevant_occupiables.present?
        bookings.joins(:occupancies).where(occupancies: { occupiable_id: relevant_occupiables })
      end
    end

    filter :categories do |bookings|
      categories = Array.wrap(categories).compact_blank
      next if categories.blank?

      category_ids = BookingCategory.where(key: categories).pluck(:id) + categories
      bookings.where(booking_category_id: category_ids)
    end

    filter :concluded do |bookings|
      include_concluded = concluded.blank? || %w[all concluded 1].include?(concluded.to_s)
      include_inconcluded = concluded.blank? || %w[all inconcluded 0].include?(concluded.to_s)
      arel_values = [include_concluded ? true : nil, include_inconcluded ? false : nil].compact

      bookings.where(concluded: arel_values)
    end

    filter :q do |bookings|
      next bookings if q.blank?

      match = "%#{q.strip}%"
      bookings.joins(:tenant)
              .where(Tenant.arel_table[:search_cache].matches(match)
              .or(Booking.arel_table[:tenant_organisation].matches(match))
              .or(Booking.arel_table[:ref].matches("#{q.strip}%")))
    end

    filter :has_booking_state do |bookings|
      states = Array.wrap(current_booking_states).compact_blank

      bookings.where(booking_state_cache: states) if states.any?
    end

    filter :had_booking_state do |bookings|
      states = Array.wrap(previous_booking_states).compact_blank

      bookings.joins(:state_transitions).where(state_transitions: { to_state: states }) if states.any?
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def derive_booking_attributes
      {}.tap do |attributes|
        attributes[:begins_at] = at_date if at_date.present?
        attributes[:begins_at] = begins_at_before || begins_at_after if begins_at_before || begins_at_after
        attributes[:ends_at] = ends_at_before || ends_at_after if ends_at_before || ends_at_after
        attributes[:home_id] = Array.wrap(homes).compact_blank.first
        attributes[:occupiable_ids] = occupiables
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  end
end
