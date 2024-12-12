# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id                  :integer          not null, primary key
#  booking_id          :uuid             not null
#  source_type         :string           not null
#  source_id           :integer          not null
#  account_nr          :string           not null
#  vat_category_id     :integer
#  date                :date             not null
#  amount              :decimal(, )      not null
#  side                :integer          not null
#  currency            :string           not null
#  text                :string
#  ordinal             :integer
#  source_document_ref :string
#  cost_center         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_journal_entries_on_source           (source_type,source_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
