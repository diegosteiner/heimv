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

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': lambda { |actual_value:, compare_value:|
                            [actual_value&.key, actual_value&.id&.to_s].compact_blank.include?(compare_value&.to_s)
                          },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_operator, presence: true
    validate do
      next if compare_values.exists?(key: compare_value) ||
              compare_values.exists?(id: compare_value)

      errors.add(:compare_value, :invalid)
    end

    def evaluate!(booking)
      actual_value = booking.category
      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: })
    end

    def compare_values
      organisation.booking_categories.ordered
    end
  end
end
