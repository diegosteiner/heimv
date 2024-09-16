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
  class BookingQuestion < BookingCondition
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    def compare_attributes
      organisation.booking_questions.index_by { _1.id.to_s.to_sym }
    end

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_operator, :compare_attribute, presence: true

    def evaluate!(booking)
      actual_value = booking.booking_question_responses.find_by(booking_question:)&.value
      cast_compare_value = booking_question&.cast(compare_value)
      return if actual_value.blank? || cast_compare_value.blank?

      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: cast_compare_value })
    end

    def booking_question
      organisation.booking_questions.find_by(id: compare_attribute)
    end

    def compare_attributes_for_select
      compare_attributes&.values&.map { |booking_question| [booking_question.label, booking_question.id] }
    end
  end
end
