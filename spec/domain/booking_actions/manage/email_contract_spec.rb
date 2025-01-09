# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::EmailContract do
  subject(:action) { described_class.new(booking) }
  subject(:invoke) { action.invoke }
  subject(:booking_after_invoke) do
    invoke
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, initial_state:) }
  let(:initial_state) { :definitive_request }
  let!(:contract) { create(:contract, booking:) }

  describe '#allowed?' do
    subject(:allowed) { action.allowed? }

    it { expect(allowed).to be_truthy }
  end

  describe '#invoke' do
    it { expect(invoke.success).to be_truthy }
    it { expect(booking_after_invoke).to notify(:awaiting_contract_notification).to(:tenant) }
    it { expect(booking_after_invoke.contract).to be_sent }
    it { expect(booking_after_invoke.notifications.last.attachments).to be_present }

    context 'with deposit' do
      let(:deposit) { create(:deposit, booking:) }

      it do
        expect(deposit.invoice_parts).to be_present
        invoke
        expect(deposit.reload).to be_sent
      end
    end
  end

  describe '#label' do
    subject(:label) { action.label }

    it { expect(label).to eq(I18n.t('booking_actions.manage.email_contract.label_without_deposit')) }

    context 'with deposit' do
      let!(:deposit) { Invoice::Factory.new.call(booking, type: Invoices::Deposit.to_s).tap(&:save) }
      it { expect(label).to eq(I18n.t('booking_actions.manage.email_contract.label_with_deposit')) }
    end
  end
end
