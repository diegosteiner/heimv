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

require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
