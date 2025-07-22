# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::EmailContract do
  subject(:booking_after_invoke) do
    invoke
    booking.notifications.each(&:deliver)
    booking
  end

  let(:action) { described_class.new(booking, :email_contract) }
  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, initial_state:) }
  let(:initial_state) { :definitive_request }
  let(:invoke) { action.invoke }

  before { create(:contract, booking:) }

  describe '#invokable?' do
    it { expect(action).to be_invokable }
  end

  describe '#invoke' do
    it { expect(invoke.success).to be_truthy }
    it { expect(booking_after_invoke).to notify(:email_contract_notification).to(:tenant) }
    it { expect(booking_after_invoke.contract).to be_sent }
    it { expect(booking_after_invoke.notifications.last.attachments).to be_present }

    context 'with deposit' do
      let(:deposit) { create(:deposit, booking:) }

      it do
        expect(deposit.invoice_parts).to be_present
        expect(booking_after_invoke.invoices.find(deposit.id)).to be_sent
      end
    end
  end

  describe '#invokable_with' do
    subject(:invokable_with) { action.invokable_with(current_user: nil) }

    it { expect(invokable_with[:label]).to eq(I18n.t('booking_actions.email_contract.label_without_invoice')) }

    context 'with deposit' do
      before { Invoice::Factory.new(booking).build(type: Invoices::Deposit.to_s).tap(&:save) }

      it { expect(invokable_with[:label]).to eq(I18n.t('booking_actions.email_contract.label_with_invoice')) }
    end
  end
end
