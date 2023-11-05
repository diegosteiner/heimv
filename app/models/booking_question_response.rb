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
  belongs_to :booking, inverse_of: :booking_question_responses, touch: true
  belongs_to :booking_question, inverse_of: :booking_question_responses

  scope :ordered, -> { joins(:booking_question).order(BookingQuestion.arel_table[:ordinal].asc) }

  validates :value, length: { maximum: 1000 }
  validate on: %i[public_create public_update] do
    errors.add(:value, :blank) if booking_question&.required && value.blank?
  end

  def editable
    return false unless booking_question
    return true if booking_question.mode_always_editable?
    return value.blank? if booking_question.mode_blank_editable?

    booking.editable
  end

  def value
    super.presence && booking_question&.cast(super)
  end

  def self.process_nested_attributes(booking, attributes, manage: false)
    existing_responses = indexed_by_booking_question_id(booking)
    attributes_by_question_id = attributes&.values&.index_by { _1[:booking_question_id]&.to_i } || {}
    questions = BookingQuestion.applying_to_booking(booking).index_by(&:id)
    questions.values.map do |question|
      attributes_of_response = attributes_by_question_id[question.id]
      build_response(booking, question, existing_responses, attributes_of_response, manage:)
    end
  end

  def self.build_response(booking, question, existing_responses, attributes, manage: false)
    existing_responses.fetch(question.id, booking.booking_question_responses.build).tap do |response|
      response.booking_question = question
      next if attributes.blank? || (!manage && question.mode_not_visible?) || (!manage && !response.editable)

      response.value = question.cast(attributes[:value])
    end
  end

  def self.indexed_by_booking_question_id(booking)
    (booking&.booking_question_responses.presence || []).index_by(&:booking_question_id)
  end
end
