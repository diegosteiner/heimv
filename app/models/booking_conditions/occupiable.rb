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
  class Occupiable < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute occupiable: ->(booking:) { booking.occupiable_ids },
                      home: ->(booking:) { booking.home_id }

    compare_operator '=': ->(actual_value:, compare_value:) { actual_value.include?(compare_value.presence&.to_i) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_attribute, :compare_operator, presence: true
    validate do
      errors.add(:compare_value, :invalid) unless compare_values.exists?(id: compare_value)
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      actual_value = Array.wrap(actual_value).compact_blank.map(&:to_i)
      evaluate_operator(compare_operator.presence || :'=', with: { actual_value:, compare_value: })
    end

    def compare_values
      organisation.occupiables.ordered
    end
  end
end
