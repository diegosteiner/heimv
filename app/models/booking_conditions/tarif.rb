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
  class Tarif < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': ->(actual_value:, compare_value:) { actual_value.include?(compare_value.presence&.to_i) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_operator, :compare_value, presence: true
    validate do
      errors.add(:compare_value, :invalid) unless compare_values.exists?(id: compare_value)
    end

    def evaluate!(booking)
      actual_value = booking.usages.map(&:tarif_id)
      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: })
    end

    def compare_values
      organisation.tarifs.ordered
    end
  end
end
