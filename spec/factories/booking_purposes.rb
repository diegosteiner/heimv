# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_purposes
#
#  id              :bigint           not null, primary key
#  key             :string
#  position        :integer
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_booking_purposes_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_booking_purposes_on_organisation_id          (organisation_id)
#  index_booking_purposes_on_position                 (position)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
FactoryBot.define do
  factory :booking_purpose do
    organisation { nil }
    key { 'MyString' }
    title_i18n { '' }
  end
end
