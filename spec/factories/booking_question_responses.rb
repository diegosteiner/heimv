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

FactoryBot.define do
  factory :booking_question_response do
    booking
    booking_question
  end
end
