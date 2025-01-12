# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :bigint           not null, primary key
#  check_on           :integer          default(0), not null
#  error_message_i18n :jsonb            not null
#  ordinal            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_booking_validations_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :booking_validation do
    organisation { nil }
    check_on { Booking::VALIDATION_CONTEXTS }
    error_message { 'Validation failed' }
  end
end
