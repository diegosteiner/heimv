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
#  trigger      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#
# Indexes
#
#  index_journal_entries_on_booking_id  (booking_id)
#  index_journal_entries_on_invoice_id  (invoice_id)
#  index_journal_entries_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
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
