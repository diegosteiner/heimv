# frozen_string_literal: true

module Public
  class BookingQuestionResponseSerializer < ApplicationSerializer
    association :booking_question, blueprint: Public::BookingQuestionSerializer

    fields :value, :booking_question_id
  end
end
