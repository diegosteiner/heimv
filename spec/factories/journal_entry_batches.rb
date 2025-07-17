# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_batches
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  entries      :jsonb
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  text         :string
#  trigger      :integer          not null
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#

FactoryBot.define do
  factory :journal_entry_batch do
    booking
    date { '2024-12-12' }
    ref { 'JournalEntryBatchRef' }
    currency { booking.organisation.currency }
    trigger { :invoice_created }
    transient do
      soll_account_nr { '1050' }
      haben_account_nr { '6000' }
      amount { 1000 }
      vat_category_id { nil }
      accounting_cost_center { nil }
      text { Faker::Commerce.department }
    end

    after(:build) do |journal_entry_batch, evaluator|
      next if journal_entry_batch.entries.present?

      journal_entry_batch.assign_attributes(entries_attributes: [
                                              {
                                                soll_account: evaluator.soll_account_nr,
                                                haben_account: evaluator.haben_account_nr,
                                                amount: evaluator.amount,
                                                text: evaluator.text,
                                                vat_category_id: evaluator.vat_category_id,
                                                cost_center: evaluator.accounting_cost_center
                                              }
                                            ])
    end

    trait :invoice_created do
      invoice
      trigger { :invoice_created }
      after(:build) do |journal_entry_batch|
        journal_entry_batch.entries = []
        factory = JournalEntryBatch::Factory.new
        factory.build_invoice_debitor(invoice, journal_entry_batch)
        invoice.invoice_parts.map { factory.build_invoice_part(it, journal_entry_batch) }
      end
    end
  end
end
