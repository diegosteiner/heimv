# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JournalEntryBatches::Payment do
  let(:organisation) { create(:organisation, :with_accounting) }
  let(:invoice) { booking.invoices.last }
  let(:payment) { create(:payment, invoice:, booking:, amount: 300, paid_at: '2024-12-27') }
  let(:booking) { create(:booking, :invoiced, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27') }

  describe '::build_with_payment' do
    subject(:journal_entry_batch) { described_class.build_with_payment(payment, trigger: :payment_created) }

    before do
      organisation.accounting_settings.payment_account_nr = '1025'
      organisation.accounting_settings.rental_yield_account_nr = '6000'
      organisation.save
    end

    context 'with payment_paid' do
      it 'builds batch with entries' do
        is_expected.to be_valid
        is_expected.to have_attributes(date: Date.new(2024, 12, 27), ref: payment.id.to_s, amount: 300.0)
        expect(journal_entry_batch.entries).to contain_exactly(
          have_attributes(soll_account: '1025', haben_account: '1050', amount: 300.0, book_type: 'main')
          # have_attributes(soll_account: '1050', haben_account: '9001', amount: 300.0, book_type: 'cost')
        )
      end
    end

    context 'with payment_writeoff' do
      let(:payment) { create(:payment, invoice:, booking:, amount: 300, paid_at: '2024-12-27', write_off: true) }

      it 'builds batch with entries' do
        is_expected.to be_valid
        is_expected.to have_attributes(date: Date.new(2024, 12, 27), ref: payment.id.to_s, amount: 300.0)
        expect(journal_entry_batch.entries).to contain_exactly(
          have_attributes(soll_account: '6000', haben_account: '1050', amount: 300.0, book_type: 'main')
        )
      end
    end
  end

  describe '::handle' do
    before do
      allow(described_class).to receive(:handle).and_call_original
    end

    it 'creates, updates and deletes the journal_entry_batches' do # rubocop:disable RSpec/NoExpectationExample
      #   expect(invoice.journal_entry_batches.where(type: described_class.sti_name).reload).to contain_exactly(
      #     have_attributes(trigger: 'invoice_created', amount: invoice.amount, processed?: be_falsy)
      #   )
      #   expect(described_class).to have_received(:handle).once

      #   process_entries(invoice)
      #   change_invoice_amount(invoice, amount: 77)

      #   expect(described_class).to have_received(:handle).twice
      #   expect(invoice.journal_entry_batches.where(type: described_class.sti_name).reload).to contain_exactly(
      #     have_attributes(trigger: 'invoice_created', amount: 420, processed?: be_truthy),
      #     have_attributes(trigger: 'invoice_updated', amount: 420, processed?: be_falsy),
      #     have_attributes(trigger: 'invoice_updated', amount: 497, processed?: be_falsy)
      #   )
      # end

      # def process_entries(invoice)
      #   invoice.journal_entry_batches.update_all(processed_at: Time.zone.now)
      # end

      # def change_invoice_amount(invoice, amount:)
      #   invoice.invoice_parts.last.update(amount: invoice.invoice_parts.last.amount + amount)
      #   invoice.save!
    end
  end
end
