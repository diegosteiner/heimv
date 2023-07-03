# frozen_string_literal: true

module Manage
  class BookingQuestionParams < ApplicationParams
    def self.permitted_keys
      %i[type label description ordinal_position key required] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "description_#{locale}"] }.flatten +
        [{ applying_conditions_attributes: BookingConditionParams.permitted_keys + %i[id _destroy],
           options: [] }]
    end

    def self.sanitize_booking_params(booking, params)
      booking_questions = booking&.organisation&.booking_questions
      return if booking_questions.empty? || params.empty?

      booking_questions.to_h do |question|
        value = question.sanitize_value(params[question.id.to_s])
        next unless question.value_valid?(value, booking: booking)

        [question.id, value]
      end
    end
  end
end
