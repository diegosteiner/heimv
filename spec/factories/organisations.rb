# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  account_address           :string
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  booking_ref_template      :string           default("")
#  cors_origins              :text
#  country_code              :string           default("CH"), not null
#  creditor_address          :text
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_template      :string           default("")
#  locale                    :string
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notifications_enabled     :boolean          default(TRUE)
#  representative_address    :string
#  settings                  :jsonb
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
    booking_flow_type { BookingFlows::Default.to_s }
    email { 'test@test.test' }
    esr_beneficiary_account { 'MyString' }
    notifications_enabled { true }
    slug { nil }
    location { nil }
    locale { I18n.locale }
    currency { 'CHF' }

    after(:build) do |organisation, _evaluator|
      build(:booking_category, key: :camp, title: 'Lager', organisation:)
      build(:booking_category, key: :private, title: 'Fest', organisation:)
    end

    trait :with_templates do
      after(:create) do |organisation|
        onboarding = OnboardingService.new(organisation)
        onboarding.create_missing_rich_text_templates!
      end
    end
  end
end
