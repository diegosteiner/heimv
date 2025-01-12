# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id              :integer          not null, primary key
#  invoice_id      :integer
#  vat_category_id :integer
#  currency        :string           not null
#  ref             :string
#  book_type       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  payment_id      :integer
#  trigger         :integer          not null
#  booking_id      :uuid             not null
#  processed_at    :datetime
#  date            :date             not null
#  fragments       :jsonb
#
# Indexes
#
#  index_journal_entries_on_booking_id       (booking_id)
#  index_journal_entries_on_invoice_id       (invoice_id)
#  index_journal_entries_on_payment_id       (payment_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

FactoryBot.define do
  factory :journal_entry do
    booking
    date { '2024-12-12' }
    ref { 'JournalEntryRef' }
    currency { booking.organisation.currency }
    transient do
      # skip_invoice_parts { false }
    end

    # account_nr { 'MyString' }
    # vat_category { nil }
    # text { 'MyString' }
    # amount { '9.99' }
    # ordinal { 1 }
    # side { 1 }

    after(:build) do |journal_entries, evaluator|
      next if evaluator.skip_invoice_parts

      if evaluator.amount&.positive?
        build(:invoice_part, amount: evaluator.amount, invoice:)
      else
        build_list(:invoice_part, 3, invoice:)
      end
    end
  end
end
