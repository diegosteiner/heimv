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

require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  let(:booking) { create(:booking) }
  let(:invoice) { create(:invoice, booking:) }

  describe '::collect' do
    subject(:journal_entries) do
      [
        described_class.collect(booking:, ref: 'test 1', date: 2.weeks.ago, trigger: :manual) do |collector|
          collector.soll(account_nr: 6000, amount: 1000)
          collector.haben(account_nr: 1000, amount: 500)
          collector.haben(account_nr: 2000, amount: 500)
        end,
        described_class.collect(booking:, ref: 'test 2', date: 1.week.ago, trigger: :manual) do |collector|
          collector.soll(account_nr: 6000, amount: 800)
          collector.haben(account_nr: 1000, amount: 800)
        end
      ]
    end

    it 'groups the compounds back together' do
      expect(journal_entries.map(&:save)).to all(be_truthy)
      expect(journal_entries).to contain_exactly(
        have_attributes(booking:, ref: 'test 1'),
        have_attributes(booking:, ref: 'test 2')
      )
      expect(journal_entries.map { _1.fragments }).to contain_exactly(
        contain_exactly(
          have_attributes(side: 'soll', account_nr: '6000', amount: 1000),
          have_attributes(side: 'haben', account_nr: '1000', amount: 500),
          have_attributes(side: 'haben', account_nr: '2000', amount: 500)
        ),
        contain_exactly(
          have_attributes(side: 'soll', account_nr: '6000', amount: 800),
          have_attributes(side: 'haben', account_nr: '1000', amount: 800)
        )
      )
    end
  end
end
