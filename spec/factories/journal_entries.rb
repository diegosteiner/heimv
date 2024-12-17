# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id                  :integer          not null, primary key
#  invoice_id          :integer          not null
#  source_type         :string
#  source_id           :integer
#  vat_category_id     :integer
#  account_nr          :string           not null
#  side                :integer          not null
#  amount              :decimal(, )      not null
#  date                :date             not null
#  text                :string
#  currency            :string           not null
#  ordinal             :integer
#  source_document_ref :string
#  book_type           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_journal_entries_on_invoice_id       (invoice_id)
#  index_journal_entries_on_source           (source_type,source_id)
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
    source_document_ref { 'MyString' }
    currency { 'MyString' }
    cost_center { 'MyString' }
  end
end
