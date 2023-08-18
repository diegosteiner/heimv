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

  validates :value, length: { maximum: 1000 }
  validate on: %i[public_create public_update] do
    errors.add(:value, :blank) if booking_question.required && value.blank?
  end

  delegate :editable, to: :booking

  def value
    super.presence && booking_question&.cast(super)
  end

  def self.process_nested_attributes(booking, attributes)
    existing_responses = indexed_by_booking_question_id(booking)
    questions = BookingQuestion.applying_to_booking(booking).index_by(&:id)
    attributes&.values&.filter_map do |attribute_set|
      question = questions[attribute_set[:booking_question_id]&.to_i]
      next if question.blank?

      response = existing_responses.fetch(question.id, booking.booking_question_responses.build)
      response.assign_attributes(booking_question: question, value: question.cast(attribute_set[:value]))
      response
    end
  end

  def self.indexed_by_booking_question_id(booking)
    (booking&.booking_question_responses.presence || []).index_by(&:booking_question_id)
  end
end
