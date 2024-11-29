# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id              :integer          not null, primary key
#  booking_id      :uuid
#  operator_id     :integer          not null
#  ordinal         :integer
#  responsibility  :integer
#  remarks         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :integer          not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#

FactoryBot.define do
  factory :operator_responsibility do
    organisation
    operator { build(:operator, organisation:) }
    responsibility { :home_handover }
    remarks { 'Some remarks about the responsibility' }
  end
end
