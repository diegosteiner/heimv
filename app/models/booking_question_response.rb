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

  delegate :ordinal, to: :booking_question, allow_nil: true

  def editable?(role) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    return false unless booking_question

    case role.to_sym
    when :manager
      return true
    when :tenant
      return false if booking_question.tenant_not_visible?
      return true if booking_question.tenant_always_editable?
      return value.blank? if booking_question.tenant_blank_editable?
    when :booking_agent
      return false if booking_question.booking_agent_not_visible?
      return true if booking_question.booking_agent_always_editable?
      return value.blank? if booking_question.booking_agent_blank_editable?
    end

    booking.editable?
  end

  def value
    super.presence && booking_question&.cast(super)
  end

  class << self
    def process(booking, params = {}, role:)
      existing_responses = indexed_by_booking_question_id(booking)
      params_by_question_id = params&.to_h&.values&.index_by { _1[:booking_question_id]&.to_i } || {}
      BookingQuestion.applying_to_booking(booking).map do |question|
        build_response(booking, question, existing_responses, params_by_question_id[question.id], role:)
      end
    end

    def build_response(booking, question, existing_responses, params = {}, role: nil)
      existing_responses.fetch(question.id, booking.booking_question_responses.build).tap do |response|
        response.booking_question = question
        next if params.blank? || !response.editable?(role)

        response.value = question.cast(params[:value])
      end
    end

    def indexed_by_booking_question_id(booking)
      (booking&.booking_question_responses.presence || []).index_by(&:booking_question_id)
    end
  end
end
