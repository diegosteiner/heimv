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

    def evaluate!(booking)
      actual_value = ComparableDatetime[evaluate_attribute(compare_attribute, with: { booking: })]
      compare_value = ComparableDatetime.from_string(self.compare_value)
      return if actual_value.blank? || compare_value.blank?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: })
    end
  end
end
