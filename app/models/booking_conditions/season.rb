# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id               :bigint           not null, primary key
#  distinction      :string
#  group            :string
#  must_condition   :boolean          default(TRUE)
#  qualifiable_type :string
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint
#  qualifiable_id   :bigint
#
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (qualifiable_id => tarifs.id)
#

module BookingConditions
  class Season < ::BookingCondition
    BookingCondition.register_subtype self

    def self.distinction_regex
      /\A(?<begin_day>\d{1,2})\.(?<begin_month>\d{1,2})\.?-(?<end_day>\d{1,2})\.(?<end_month>\d{1,2})\.?\z/
    end

    validate do
      errors.add(:distinction, :invalid) if season_span(Time.zone.now.year).blank?
    end

    def evaluate(booking)
      occupancy = booking.occupancy
      years = [occupancy&.begins_at&.year, occupancy&.ends_at&.year]
      phased_season_spans(years).any? { |season| season.overlaps?(occupancy.span) }
    end

    protected

    def season_span(year)
      return unless distinction_match

      begins_at = Time.zone.local(year, distinction_match[:begin_month], distinction_match[:begin_day])
      ends_at = Time.zone.local(year, distinction_match[:end_month], distinction_match[:end_day])
      ends_at += 1.year if begins_at > ends_at
      Range.new(begins_at.beginning_of_day, ends_at.end_of_day)
    rescue ArgumentError
      nil
    end

    def phased_season_spans(years)
      years = Array.wrap(years)
      years += [years.min - 1, years.max + 1] if years.min && years.max
      years.compact.uniq.sort.map { |year| season_span(year) }.compact
    end
  end
end
