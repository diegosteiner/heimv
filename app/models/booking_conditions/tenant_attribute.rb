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
  class TenantAttribute < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute country_code: ->(tenant:) { tenant&.country_code&.upcase }

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_attribute, :compare_operator, presence: true

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { tenant: booking.tenant })
      return if actual_value.blank? || compare_value.blank?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: })
    end
  end
end
