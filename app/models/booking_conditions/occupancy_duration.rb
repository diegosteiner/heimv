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
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module BookingConditions
  class OccupancyDuration < ::BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    def compare_operators
      NUMERIC_OPERATORS
    end

    def compare_value_regex
      /\A(?<threshold>\d+)\s*(?<threshold_unit>[smhd])\z/
    end

    def evaluate!(booking)
      compare_value_match = compare_value_regex.match(compare_value)
      return false unless compare_value_match

      compare_value = threshold_unit(compare_value_match[:threshold], compare_value_match[:threshold_unit])
      evaluate_operator(compare_operator.presence || :'=', with: { actual_value: booking.duration, compare_value: })
    end

    protected

    def threshold_unit(value, unit)
      value = value.to_i
      return value.days if unit == 'd'
      return value.hours if unit == 'h'
      return value.minutes if unit == 'm'

      value.second
    end
  end
end
