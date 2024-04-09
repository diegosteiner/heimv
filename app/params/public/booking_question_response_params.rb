# frozen_string_literal: true

module Public
  class BookingQuestionResponseParams < ApplicationParamsSchema
    define do
      required(:booking_question_id).filled(:integer)
      required(:value).maybe(:string)
    end
  end
end
