# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_question_responses
#
#  id                  :bigint           not null, primary key
#  value               :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid             not null
#  booking_question_id :bigint           not null
#
# Indexes
#
#  index_booking_question_responses_on_booking_question_id  (booking_question_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_question_id => booking_questions.id)
#
class BookingQuestionResponse < ApplicationRecord
  belongs_to :booking, inverse_of: :booking_question_responses
  belongs_to :booking_question, inverse_of: :booking_question_responses

  scope :ordered, -> { joins(:booking_question).order(BookingQuestion.arel_table[:ordinal].asc) }

  # def self.for_booking(booking, **rest)
  #   existing_responses = booking.booking_question_responses.index_by(&:booking_question_id)
  #   questions = booking.organisation.booking_questions.filter { |question| question.applies_to_booking?(booking) }
  #   questions.map do |question|
  #     existing_responses[question.id] ||
  #       booking.booking_question_responses.build(rest.merge(booking_question: question))
  #   end
  # end

  def self.prepare_booking(booking)
    booking.booking_questions = BookingQuestion.applying_to_booking(booking)
  end
end
