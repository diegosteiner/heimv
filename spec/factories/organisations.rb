# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_ref_strategy_type :string
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  email                     :string
#  esr_participant_nr        :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_strategy_type :string
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notification_footer       :text
#  notifications_enabled     :boolean          default(TRUE)
#  payment_deadline          :integer          default(30), not null
#  representative_address    :string
#  slug                      :string
#  smtp_settings             :jsonb
#  users_limit               :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_organisations_on_slug  (slug) UNIQUE
#

FactoryBot.define do
  factory :organisation do
    name { 'Heimverein St. Georg' }
    address { 'MyText' }
    booking_strategy_type { BookingStrategies::Default.to_s }
    invoice_ref_strategy_type { RefStrategies::ESR.to_s }
    booking_ref_strategy_type { RefStrategies::DefaultBookingRef.to_s }
    email { 'test@test.test' }
    esr_participant_nr { 'MyString' }
    notifications_enabled { true }
    slug { nil }
    location { nil }

    trait :with_markdown_templates do
      after(:create) do |organisation|
        onboarding = OrganisationSetupService.new(organisation)
        onboarding.create_missing_markdown_templates!
      end
    end
  end
end
