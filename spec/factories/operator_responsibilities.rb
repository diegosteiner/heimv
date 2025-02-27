# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id                  :bigint           not null, primary key
#  applying_conditions :jsonb
#  ordinal             :integer
#  remarks             :text
#  responsibility      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  operator_id         :bigint           not null
#  organisation_id     :bigint           not null
#

FactoryBot.define do
  factory :operator_responsibility do
    organisation
    operator { build(:operator, organisation:) }
    responsibility { :home_handover }
    remarks { 'Some remarks about the responsibility' }
  end
end
