# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :integer          not null, primary key
#  organisation_id    :integer          not null
#  error_message_i18n :jsonb
#  ordinal            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_booking_validations_on_organisation_id  (organisation_id)
#

FactoryBot.define do
  factory :booking_validation do
    organisation { nil }
    check_on { Booking::VALIDATION_CONTEXTS }
    error_message_i18n { 'Validation failed' }
  end
end
