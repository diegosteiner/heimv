# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                           :bigint           not null, primary key
#  account_address              :string
#  accounting_settings          :jsonb
#  address                      :text
#  bcc                          :string
#  booking_flow_type            :string
#  booking_ref_template         :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_ref_alpha>s")
#  booking_state_settings       :jsonb
#  cors_origins                 :text
#  country_code                 :string           default("CH"), not null
#  creditor_address             :text
#  currency                     :string           default("CHF")
#  deadline_settings            :jsonb
#  default_payment_info_type    :string
#  email                        :string
#  esr_beneficiary_account      :string
#  esr_ref_prefix               :string
#  homes_limit                  :integer
#  iban                         :string
#  invoice_payment_ref_template :string           default("%<prefix>s%<tenant_sequence_number>06d%<sequence_year>04d%<sequence_number>05d")
#  invoice_ref_template         :string
#  locale                       :string
#  location                     :string
#  mail_from                    :string
#  name                         :string
#  nickname_label_i18n          :jsonb
#  notifications_enabled        :boolean          default(TRUE)
#  qr_bill_creditor_address     :jsonb
#  representative_address       :string
#  settings                     :jsonb
#  slug                         :string
#  smtp_settings                :jsonb
#  tenant_ref_template          :string
#  users_limit                  :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

FactoryBot.define do
  factory :organisation do
    name { 'Heimverein Pfadi Stolz' }
    address { 'MyText' }
    booking_flow_type { BookingFlows::Default.to_s }
    email { 'test@test.test' }
    esr_beneficiary_account { 'MyString' }
    notifications_enabled { true }
    slug { nil }
    location { nil }
    locale { I18n.locale }
    currency { 'CHF' }
    booking_ref_template { RefBuilders::Booking::DEFAULT_TEMPLATE }
    tenant_ref_template { RefBuilders::Tenant::DEFAULT_TEMPLATE }
    invoice_ref_template { RefBuilders::Invoice::DEFAULT_TEMPLATE }
    invoice_payment_ref_template { RefBuilders::InvoicePayment::DEFAULT_TEMPLATE }

    after(:build) do |organisation, _evaluator|
      build(:booking_category, key: :camp, title: 'Lager', organisation:)
      build(:booking_category, key: :private, title: 'Fest', organisation:)
    end

    trait :with_templates do
      after(:create) do |organisation|
        onboarding = OnboardingService.new(organisation)
        onboarding.setup_missing_rich_text_templates
        organisation.rich_text_templates.update_all(enabled: true) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    trait :with_accounting do
      after(:build) do |organisation|
        organisation.accounting_settings.enabled = true
        organisation.accounting_settings.debitor_account_nr ||= '1050'
        organisation.accounting_settings.rental_yield_account_nr ||= '6000'
        organisation.accounting_settings.vat_account_nr ||= '2016'
        organisation.accounting_settings.payment_account_nr ||= '1025'
        organisation.accounting_settings.liable_for_vat ||= true
      end

      after(:create) do |organisation|
        organisation.accounting_settings.rental_yield_vat_category_id ||= create(:vat_category, organisation:).id
        organisation.save
      end
    end
  end
end
