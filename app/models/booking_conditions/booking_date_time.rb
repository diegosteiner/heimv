# frozen_string_literal: true

module BookingConditions
  class BookingDateTime < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator(**NUMERIC_OPERATORS)

    compare_attribute begins_at: ->(booking:) { booking.begins_at },
                      ends_at: ->(booking:) { booking.ends_at },
                      created_at: ->(booking:) { booking.created_at },
                      updated_at: ->(booking:) { booking.updated_at },
                      deadline: ->(booking:) { booking.deadline&.at },
                      now: ->(booking:) { Time.zone.today } # rubocop:disable Lint/UnusedBlockArgument

    validates :compare_attribute, :compare_operator, presence: true

    def self.compare_value_regex
      ComparableDatetime::REGEX
    end

    def comparable_compare_value
      ComparableDatetime.from_string(compare_value)
    end

    def evaluate!(booking)
      actual_value = ComparableDatetime.from_value(evaluate_attribute(compare_attribute, with: { booking: }))
      return if actual_value.blank? || comparable_compare_value.blank?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: comparable_compare_value })
    end

    # paradox conditions are BookinDateTime conditions that can never be true all at the same time. E.g.
    # when checking if a booking_date is in winter, it must be either > *-09-31 or < *-03-01. This
    # can be detected, and mitigated by rewiring the #fullfills? logic to allow either condition to
    # be true.
    # TODO: Add OR construct to conditions and migrate these paradox conditions
  end
end
