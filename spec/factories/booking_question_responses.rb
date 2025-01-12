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

FactoryBot.define do
  factory :booking_question_response do
    booking
    booking_question
  end
end
