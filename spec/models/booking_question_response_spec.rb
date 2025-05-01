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

require 'rails_helper'

RSpec.describe BookingQuestionResponse do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }

  describe '#process' do
    def process = BookingQuestionResponse.process(booking, responses_params, role:)
    let(:responses_params) { {} }
    let(:role) { :tenant }

    it 'keeps the order of questions and responses' do
      3.times { |i| create(:booking_question, ordinal: (3 - i), organisation:, label: "Q#{i + 1}") }
      process
      expect(booking.booking_question_responses.map { it.booking_question.label }).to eq(%w[Q3 Q2 Q1])
      create(:booking_question, ordinal: 2, organisation:, label: 'Q4')
      booking.booking_question_responses.reload
      process
      expect(booking.booking_question_responses.map { it.booking_question.label }).to eq(%w[Q3 Q4 Q2 Q1])
    end
  end
end
