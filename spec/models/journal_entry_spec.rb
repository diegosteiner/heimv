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
    let(:amount) { 500 }
    let(:ref) { 'test' }
    let(:date) { Time.zone.today }

    subject(:compound) do
      described_class.collect(booking:, ref:, date:, trigger: :manual) do |compound|
        compound.soll(account_nr: 6000, amount:)
        compound.haben(account_nr: 1000, amount:)
      end
    end

    it 'collects the journal entries as compound' do
      expect(compound).to be_a(JournalEntry::Compound)
      expect(compound.journal_entries).to contain_exactly(
        have_attributes(side: 'soll', account_nr: '6000', book_type: 'main', amount:, booking:, ref:, date:),
        have_attributes(side: 'haben', account_nr: '1000', book_type: 'main', amount:, booking:, ref:, date:)
      )
      expect(compound).to be_valid
      compound.save!
      expect(compound.journal_entries).to all(be_persisted)
    end
  end

  describe '::compounds' do
    subject(:compounds) { JournalEntry::Compound.group(described_class.all) }
    before do
      described_class.collect(booking:, ref: 'test 1', date: 2.weeks.ago, trigger: :manual) do |compound|
        compound.soll(account_nr: 6000, amount: 1000)
        compound.haben(account_nr: 1000, amount: 500)
        compound.haben(account_nr: 2000, amount: 500)
      end.save!
      described_class.collect(booking:, ref: 'test 2', date: 1.week.ago, trigger: :manual) do |compound|
        compound.soll(account_nr: 6000, amount: 800)
        compound.haben(account_nr: 1000, amount: 800)
      end.save!
    end

    it 'groups the compounds back together' do
      expect(compounds.map(&:journal_entries)).to contain_exactly(
        contain_exactly(
          have_attributes(side: 'soll', account_nr: '6000', amount: 1000, booking:, ref: 'test 1'),
          have_attributes(side: 'haben', account_nr: '1000', amount: 500, booking:, ref: 'test 1'),
          have_attributes(side: 'haben', account_nr: '2000', amount: 500, booking:, ref: 'test 1')
        ),
        contain_exactly(
          have_attributes(side: 'soll', account_nr: '6000', amount: 800, booking:, ref: 'test 2'),
          have_attributes(side: 'haben', account_nr: '1000', amount: 800, booking:, ref: 'test 2')
        )
      )
    end
  end
end
