# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JournalEntryBatches::Invoice do
  let(:organisation) { create(:organisation, :with_accounting) }
  let(:invoice) { booking.invoices.last }
  let(:vat_category) { create(:vat_category, organisation:, percentage: 50, accounting_vat_code: 'VAT50') }
  let(:booking) do
    create(:booking, :invoiced, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27',
                                prepaid_amount: 300, vat_category:)
  end

  describe '::build_with_invoice' do
    subject(:journal_entry_batch) { described_class.build_with_invoice(invoice, trigger: :invoice_created) }

    before do
      organisation.accounting_settings.rental_yield_vat_category_id = vat_category.id
      organisation.save
    end

    it 'builds batch with entries' do
      is_expected.to be_valid
      is_expected.to have_attributes(date: Date.new(2024, 12, 27), ref: '250001', amount: 420.0)
      expect(journal_entry_batch.entries).to contain_exactly(
        have_attributes(soll_account: '1050', haben_account: '6000', amount: -200.0, book_type: 'main'),
        have_attributes(soll_account: '1050', haben_account: '9001', amount: -200.0, book_type: 'cost'),
        have_attributes(soll_account: '1050', haben_account: '2016', amount: -100.0, book_type: 'vat'),
        have_attributes(soll_account: '1050', haben_account: '6000', amount: 480.0, book_type: 'main'),
        have_attributes(soll_account: '1050', haben_account: '9001', amount: 480.0, book_type: 'cost'),
        have_attributes(soll_account: '1050', haben_account: '2016', amount: 240.0, book_type: 'vat')
      )
    end
  end

  describe '::handle' do
    before do
      allow(described_class).to receive(:handle).and_call_original
    end

    it 'creates, updates and deletes the journal_entry_batches' do # rubocop:disable RSpec/ExampleLength
      expect(invoice.journal_entry_batches.where(type: described_class.sti_name).reload).to contain_exactly(
        have_attributes(trigger: 'invoice_created', amount: invoice.amount, processed?: be_falsy)
      )
      expect(described_class).to have_received(:handle).once

      process_entries(invoice)
      change_invoice_amount(invoice, amount: 77)

      expect(described_class).to have_received(:handle).twice
      expect(invoice.journal_entry_batches.where(type: described_class.sti_name).reload).to contain_exactly(
        have_attributes(trigger: 'invoice_created', amount: 420, processed?: be_truthy),
        have_attributes(trigger: 'invoice_updated', amount: 420, processed?: be_falsy),
        have_attributes(trigger: 'invoice_updated', amount: 497, processed?: be_falsy)
      )
    end

    def process_entries(invoice)
      invoice.journal_entry_batches.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    end

    def change_invoice_amount(invoice, amount:)
      invoice.invoice_parts.last.update(amount: invoice.invoice_parts.last.amount + amount)
      invoice.save!
    end
  end
end
