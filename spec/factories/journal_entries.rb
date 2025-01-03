# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id              :integer          not null, primary key
#  invoice_id      :integer
#  vat_category_id :integer
#  account_nr      :string           not null
#  side            :integer          not null
#  amount          :decimal(, )      not null
#  date            :date             not null
#  text            :string
#  currency        :string           not null
#  ordinal         :integer
#  ref             :string
#  book_type       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  invoice_part_id :integer
#  payment_id      :integer
#  trigger         :integer          not null
#  booking_id      :uuid             not null
#  processed_at    :datetime
#
# Indexes
#
#  index_journal_entries_on_booking_id       (booking_id)
#  index_journal_entries_on_invoice_id       (invoice_id)
#  index_journal_entries_on_invoice_part_id  (invoice_part_id)
#  index_journal_entries_on_payment_id       (payment_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

FactoryBot.define do
  factory :journal_entry do
    booking { nil }
    source { nil }
    account_nr { 'MyString' }
    date { '2024-12-12' }
    vat_category { nil }
    text { 'MyString' }
    amount { '9.99' }
    ordinal { 1 }
    side { 1 }
    ref { 'MyString' }
    currency { 'MyString' }
    cost_center { 'MyString' }
  end
end
