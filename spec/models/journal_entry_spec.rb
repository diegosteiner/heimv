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

require 'rails_helper'

RSpec.describe JournalEntry do
  subject(:builder) { JournalEntry::Factory.new }

  let(:booking) { create(:booking, organisation:) }
  let(:invoice) { create(:invoice, booking:) }
  let(:organisation) { create(:organisation, :with_accounting) }

  describe '::new' do
    subject(:journal_entries) do
      [
        described_class.new(booking:, ref: 'test1', date: 2.weeks.ago, trigger: :invoice_updated).tap do |journal_entry|
          journal_entry.soll(account_nr: 6000, amount: 1000)
          journal_entry.haben(account_nr: 1000, amount: 500)
          journal_entry.haben(account_nr: 2000, amount: 500)
        end,
        described_class.new(booking:, ref: 'test2', date: 1.week.ago, trigger: :invoice_updated).tap do |journal_entry|
          journal_entry.soll(account_nr: 6000, amount: 800)
          journal_entry.haben(account_nr: 1000, amount: 800)
        end
      ]
    end

    it 'builds the journal entry and fragments' do
      expect(journal_entries.map(&:save)).to all(be_truthy)
      expect(journal_entries).to contain_exactly(
        have_attributes(booking:, ref: 'test1'),
        have_attributes(booking:, ref: 'test2')
      )
      expect(journal_entries.map { it.fragments }).to contain_exactly(
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

  describe '::Factory.invoice_created_journal_entry' do
    subject(:journal_entries) { invoice.journal_entries.invoice }

    let(:organisation) { create(:organisation, :with_accounting) }
    let(:vat_category) { create(:vat_category, organisation:, percentage: 50, accounting_vat_code: 'VAT50') }
    let(:invoice) { booking.invoices.last }
    let(:booking) do
      create(:booking, :invoiced, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27', prepaid_amount: 300,
                                  vat_category:)
    end

    before do
      organisation.accounting_settings.rental_yield_vat_category_id = vat_category.id
      organisation.save
    end

    it 'creates to correct journal_entries' do
      is_expected.to all(be_balanced)
      is_expected.to match_array(
        have_attributes(date: Date.new(2024, 12, 27), trigger: 'invoice_created', ref: '250001', amount: 420.0)
      )
      fragments = journal_entries.first.fragments

      expect(fragments).to contain_exactly(
        have_attributes(account_nr: '1050', soll_amount: 420.0, book_type: 'main'),
        have_attributes(account_nr: '6000', haben_amount: -200.0, book_type: 'main'),
        have_attributes(account_nr: '9001', haben_amount: -200.0, book_type: 'cost'),
        have_attributes(account_nr: '2016', haben_amount: -100.0, book_type: 'vat'),
        have_attributes(account_nr: '6000', haben_amount: 480.0, book_type: 'main'),
        have_attributes(account_nr: '9001', haben_amount: 480.0, book_type: 'cost'),
        have_attributes(account_nr: '2016', haben_amount: 240.0, book_type: 'vat')
      )
    end

    context 'with update after processed' do
      before do
        # create invoice, process journal entries and update invoice
        invoice.journal_entries.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
        invoice.invoice_parts.last.update!(amount: 1000)
        invoice.save!
      end

      it 'creates new journal entries when the invoice is updated' do
        is_expected.to contain_exactly(
          have_attributes(trigger: 'invoice_created', amount: 420.0, processed?: be_truthy),
          have_attributes(trigger: 'invoice_updated', amount: 420.0, processed?: be_falsy), have_attributes(trigger: 'invoice_updated', amount: 700.0, processed?: be_falsy)
        )
      end
    end
  end

  describe '::Factory.build_with_payment_write_off' do
    subject(:journal_entry) { builder.build_with_payment(payment) }

    context 'with normal payment' do
      let(:payment) { create(:payment, booking:, amount: 420.0, write_off: false, invoice: nil) }

      it 'creates new journal entry' do
        is_expected.to have_attributes(trigger: 'payment_created', amount: 420.0, processed?: false, payment:)
        expect(journal_entry.fragments).to contain_exactly(
          have_attributes(account_nr: '1050', haben_amount: 420.0, book_type: 'main'),
          have_attributes(account_nr: '1025', soll_amount: 420.0, book_type: 'main')
        )
      end
    end

    context 'with write off payment' do
      let(:payment) { create(:payment, booking:, amount: 420.0, write_off: true, invoice: nil) }

      it 'creates new journal entry' do
        is_expected.to have_attributes(trigger: 'payment_created', amount: 420.0, processed?: false, payment:)
        expect(journal_entry.fragments).to contain_exactly(
          have_attributes(account_nr: '6000', haben_amount: 420.0, book_type: 'main'),
          have_attributes(account_nr: '1050', soll_amount: 420.0, book_type: 'main')
        )
      end
    end
  end
end
