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
  class BookingAttribute < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute nights: ->(booking:) { booking.nights },
                      days: ->(booking:) { booking.nights + 1 },
                      tenant_organisation: ->(booking:) { booking.tenant_organisation },
                      approximate_headcount: ->(booking:) { booking.approximate_headcount },
                      overnight_stays: ->(booking:) { booking.approximate_headcount * booking.nights }

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_attribute, :compare_operator, presence: true

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      cast_compare_value = case compare_attribute&.to_sym
                           when :nights, :days, :approximate_headcount, :overnight_stays
                             compare_value&.to_i
                           else
                             compare_value.presence
                           end
      return if actual_value.blank? || cast_compare_value.blank?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: cast_compare_value })
    end
  end
end
