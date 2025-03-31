# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id                :bigint           not null, primary key
#  compare_attribute :string
#  compare_operator  :string
#  compare_value     :string
#  group             :string
#  must_condition    :boolean          default(TRUE)
#  qualifiable_type  :string
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :bigint
#  qualifiable_id    :bigint
#

module BookingConditions
  class BookingDateTime < ::BookingCondition
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

    def compare_value_regex
      ComparableDatetime::REGEX
    end

    def comparable_compare_value
      ComparableDatetime.from_string(compare_value)
    end

    def evaluate!(booking)
      actual_value = ComparableDatetime[evaluate_attribute(compare_attribute, with: { booking: })]
      return if actual_value.blank? || comparable_compare_value.blank?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: comparable_compare_value })
    end

    # paradox conditions are BookinDateTime conditions that can never be true all at the same time. E.g.
    # when checking if a booking_date is in winter, it must be either > *-09-31 or < *-03-01. This
    # can be detected, and mitigated by rewiring the #fullfills? logic to allow either condition to
    # be true.
    # TODO: Add OR construct to conditions and migrate these paradox conditions
    def paradox_conditions
      return @paradox_conditions if @paradox_conditions

      conditions_in_same_context = qualifiable.booking_conditions.where(group:, type: self.class.sti_name)
      lt_condition = conditions_in_same_context.find { %i[< <=].include?(it.compare_operator&.to_sym) }
      gt_condition = conditions_in_same_context.find { %i[> >=].include?(it.compare_operator&.to_sym) }

      return unless  lt_condition && gt_condition
      return unless lt_condition.comparable_compare_value < gt_condition.comparable_compare_value

      @paradox_conditions = [lt_condition, gt_condition]
    end

    def evaluate_other_paradox_condition(booking)
      return nil if paradox_conditions.blank?

      other_paradox_condition = paradox_conditions.first { it != self }
      other_paradox_condition&.evaluate!(booking)
    end

    def fullfills?(booking)
      evaluate(booking) ||
        evaluate_other_paradox_condition(booking) ||
        (must_condition ? false : nil)
    end
  end
end
