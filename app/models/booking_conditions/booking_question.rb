# frozen_string_literal: true

module BookingConditions
  class BookingQuestion < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_operator, :compare_attribute, presence: true

    def evaluate!(booking)
      actual_value = booking.booking_question_responses.find_by(booking_question:)&.value
      cast_compare_value = booking_question&.cast(compare_value)

      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: cast_compare_value })
    end

    def booking_question
      organisation&.booking_questions&.find_by(id: compare_attribute)
    end

    def self.compare_attributes(organisation)
      organisation&.booking_questions&.index_by { it.id.to_s.to_sym }
    end

    def self.compare_attributes_for_select(organisation)
      booking_questions = organisation.booking_questions.index_by { it.id.to_s.to_sym }
      booking_questions.values.map { |booking_question| [booking_question.label, booking_question.id] }
    end
  end
end
