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
  class Duration < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute now_to_begins_at: ->(booking:) { booking.begins_at - Time.zone.now },
                      now_to_ends_at: ->(booking:) { booking.ends_at - Time.zone.now },
                      begins_at_to_ends_at: ->(booking:) { Time.zone.now - booking.ends_at },
                      created_at_to_now: ->(booking:) { Time.zone.now - booking.created_at - Time.zone.now }

    validates :compare_attribute, :compare_operator, presence: true

    compare_operator(**NUMERIC_OPERATORS)

    def self.compare_value_regex
      /^-?P(?!$)(\d+Y)?(\d+M)?(\d+W)?(\d+D)?(T(?=\d)(\d+H)?(\d+M)?(\d+S)?)?$/
    end

    def comparable_compare_value
      return @comparable_compare_value if @comparable_compare_value
      return if compare_value.nil?

      negative = compare_value.start_with?('-')
      @comparable_compare_value = ActiveSupport::Duration.parse(compare_value.delete_prefix('-'))&.to_i
      @comparable_compare_value *= -1 if @comparable_compare_value.present? && negative
      @comparable_compare_value
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      return if actual_value.nil? || comparable_compare_value.nil?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: comparable_compare_value })
    end
  end
end
