# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id                  :bigint           not null, primary key
#  applying_conditions :jsonb
#  booking_agent_mode  :integer          default("not_visible")
#  description_i18n    :jsonb            not null
#  discarded_at        :datetime
#  key                 :string
#  label_i18n          :jsonb            not null
#  options             :jsonb
#  ordinal             :integer
#  required            :boolean          default(FALSE)
#  tenant_mode         :integer          default("not_visible"), not null
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organisation_id     :bigint           not null
#
FactoryBot.define do
  factory :booking_question do
    label { 'Anzahl Kinder?' }
    description { 'Bitte Kinder' }
    organisation
    required { false }
    type { BookingQuestions::Integer.to_s }
  end
end
