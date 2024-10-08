# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :bigint           not null, primary key
#  error_message_i18n :jsonb
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
    error_message_i18n { '' }
  end
end
