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
  class Occupiable < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    def compare_attributes
      {
        occupiable: ->(booking:) { booking.occupiable_ids },
        home: ->(booking:) { booking.home_id }
      }.freeze
    end

    def compare_operators
      {
        '=': lambda { |actual_value:, compare_value:|
               Array.wrap(actual_value).compact_blank.map(&:to_i).include?(compare_value.presence&.to_i)
             },
        '!=': ->(actual_value:, compare_value:) { !evaluate_operator(:'=', with: { actual_value:, compare_value: }) }
      }.freeze
    end

    validate do
      errors.add(:compare_value, :invalid) unless compare_values.exists?(id: compare_value)
      errors.add(:compare_operator, :invalid) unless compare_operators.keys.include?(compare_operator&.to_sym)
      errors.add(:compare_attributes, :invalid) unless compare_attributes.keys.include?(compare_attribute&.to_sym)
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      evaluate_operator(compare_operator.presence || :'=', with: { actual_value:, compare_value: })
    end

    def compare_values
      organisation.occupiables.ordered
    end
  end
end
