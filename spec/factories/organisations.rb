# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  booking_ref_strategy_type :string
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  domain                    :string
#  email                     :string
#  esr_participant_nr        :string
#  iban                      :string
#  invoice_ref_strategy_type :string
#  location                  :string
#  message_footer            :text
#  messages_enabled          :boolean          default(TRUE)
#  name                      :string
#  payment_deadline          :integer          default(30), not null
#  representative_address    :string
#  smtp_url                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
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
    messages_enabled { true }
    domain { '' }
    location {}

    trait :with_markdown_templates do
      after(:create) do |organisation|
        organisation.missing_markdown_templates.each do |locale_key|
          organisation.markdown_templates.create(locale_key)
        end
      end
    end
  end
end
