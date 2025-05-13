# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  text         :string
#  trigger      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#

FactoryBot.define do
  factory :journal_entry do
    booking
    date { '2024-12-12' }
    ref { 'JournalEntryRef' }
    currency { booking.organisation.currency }
    trigger { :invoice_updated }
    transient do
      soll_account_nr { '1050' }
      haben_account_nr { '6000' }
      amount { 1000 }
      vat_category_id { nil }
      text { Faker::Commerce.department }
    end

    after(:build) do |journal_entry, evaluator|
      next if journal_entry.fragments.present?

      journal_entry.assign_attributes(fragments_attributes: [
                                        {
                                          account_nr: evaluator.soll_account_nr,
                                          amount: evaluator.amount,
                                          text: evaluator.text, side: :soll,
                                          vat_category_id: evaluator.vat_category_id
                                        },
                                        {
                                          account_nr: evaluator.haben_account_nr,
                                          amount: evaluator.amount,
                                          text: evaluator.text, side: :haben,
                                          vat_category_id: evaluator.vat_category_id
                                        }
                                      ])
    end

    trait :invoice_created do
      invoice
      trigger { :invoice_created }
      after(:build) do |journal_entry|
        journal_entry.fragments = []
        factory = JournalEntry::Factory.new
        factory.build_invoice_debitor(invoice, journal_entry)
        invoice.invoice_parts.map { factory.build_invoice_part(it, journal_entry) }
      end
    end
  end
end
