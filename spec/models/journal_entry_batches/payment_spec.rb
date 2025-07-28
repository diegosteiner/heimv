# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_batches
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  entries      :jsonb
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  text         :string
#  trigger      :integer          not null
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#
require 'rails_helper'

RSpec.describe JournalEntryBatches::Payment do
  let(:organisation) { create(:organisation, :with_accounting) }
  let(:invoice) { booking.invoices.last }
  let(:booking) { create(:booking, :invoiced, organisation:, begins_at: '2024-12-20', ends_at: '2024-12-27') }
  let(:paid_at) { booking.ends_at }
  let(:payment) { create(:payment, invoice:, booking:, amount: 300, paid_at:, accounting_cost_center_nr: '9001') }

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
          have_attributes(soll_account: '1025', haben_account: '1050', amount: 300.0)
        )
      end
    end

    context 'with payment_payback' do
      let(:payment) { create(:payment, invoice:, booking:, amount: -300, paid_at:, accounting_cost_center_nr: '9001') }

      it 'builds batch with entries' do
        is_expected.to be_valid
        is_expected.to have_attributes(date: Date.new(2024, 12, 27), ref: payment.id.to_s, amount: 300.0)
        expect(journal_entry_batch.entries).to contain_exactly(
          # have_attributes(soll_account: '1025', haben_account: '1050', amount: -300.0)
          have_attributes(soll_account: '1050', haben_account: '1025', amount: 300.0, cost_center: '9001')
        )
      end
    end

    context 'with payment_writeoff' do
      let(:payment) { create(:payment, invoice:, booking:, amount: 300, paid_at:, write_off: true) }

      it 'builds batch with entries' do
        is_expected.to be_valid
        is_expected.to have_attributes(date: Date.new(2024, 12, 27), ref: payment.id.to_s, amount: 300.0)
        expect(journal_entry_batch.entries).to contain_exactly(
          have_attributes(soll_account: '6000', haben_account: '1050', amount: 300.0)
        )
      end
    end
  end

  describe '::handle' do
    subject(:journal_entry_batches) { payment.journal_entry_batches.where(type: described_class.sti_name) }

    before { allow(described_class).to receive(:handle).and_call_original }

    it 'creates, updates and deletes the journal_entry_batches' do # rubocop:disable RSpec/ExampleLength
      expect(journal_entry_batches.reload).to contain_exactly(
        have_attributes(trigger: 'payment_created', amount: payment.amount, processed?: be_falsy)
      )
      expect(described_class).to have_received(:handle).twice

      journal_entry_batches.update_all(processed_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
      payment.update(amount: 350)

      expect(described_class).to have_received(:handle).exactly(3).times
      expect(journal_entry_batches.reload).to contain_exactly(
        have_attributes(trigger: 'payment_created', amount: 300, processed?: be_truthy),
        have_attributes(trigger: 'payment_reverted', amount: 300, processed?: be_falsy),
        have_attributes(trigger: 'payment_updated', amount: 350, processed?: be_falsy)
      )
    end
  end
end
