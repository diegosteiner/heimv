# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_question_responses
#
#  id                  :integer          not null, primary key
#  booking_id          :uuid             not null
#  booking_question_id :integer          not null
#  value               :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_booking_question_responses_on_booking_question_id  (booking_question_id)
#

require 'rails_helper'

RSpec.describe BookingQuestionResponse, type: :model do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }

  describe '#process' do
    def process = BookingQuestionResponse.process(booking, responses_params, role:)
    let(:responses_params) { {} }
    let(:role) { :tenant }

    it 'keeps the order of questions and responses' do
      3.times { |i| create(:booking_question, ordinal: (3 - i), organisation:, label: "Q#{i + 1}") }
      process
      expect(booking.booking_question_responses.map { _1.booking_question.label }).to eq(%w[Q3 Q2 Q1])
      create(:booking_question, ordinal: 2, organisation:, label: 'Q4')
      booking.booking_question_responses.reload
      process
      expect(booking.booking_question_responses.map { _1.booking_question.label }).to eq(%w[Q3 Q4 Q2 Q1])
    end
  end
end
