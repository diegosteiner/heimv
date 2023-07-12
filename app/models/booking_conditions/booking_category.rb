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
  class BookingCategory < BookingCondition
    BookingCondition.register_subtype self

    validate do
      next if compare_values.exists?(key: compare_value) ||
              compare_values.exists?(id: compare_value)

      errors.add(:compare_value, :invalid)
    end

    def evaluate(booking)
      compare_value == booking.category&.key ||
        compare_value == booking.category&.id&.to_s
    end

    def compare_values
      organisation.booking_categories.ordered
    end
  end
end
