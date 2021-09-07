# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_strategy_type :string
#  invoice_ref_template      :string           default("%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d")
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notifications_enabled     :boolean          default(TRUE)
#  payment_deadline          :integer          default(30), not null
#  ref_template              :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s")
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
    invoice_ref_strategy_type { RefStrategies::ESR.to_s }
    email { 'test@test.test' }
    esr_beneficiary_account { 'MyString' }
    notifications_enabled { true }
    slug { nil }
    location { nil }

    after(:build) do |organisation, _evaluator|
      build(:booking_purpose, key: :camp, title: 'Lager', organisation: organisation)
      build(:booking_purpose, key: :private, title: 'Fest', organisation: organisation)
    end

    trait :with_rich_text_templates do
      after(:create) do |organisation|
        onboarding = OrganisationSetupService.new(organisation)
        onboarding.create_missing_rich_text_templates!
      end
    end
  end
end
