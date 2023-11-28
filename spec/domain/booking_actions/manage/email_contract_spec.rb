# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::EmailContract do
  subject(:action) { described_class.new(booking:) }
  subject(:call) { described_class.call(booking:) }
  subject(:booking_after_call) do
    call
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

  describe '#call!' do
    it { expect(call.ok).to be_truthy }
    it { expect(booking_after_call).to notify(:awaiting_contract_notification).to(:tenant) }
    it { expect(booking_after_call.contract).to be_sent }

    context 'with deposit' do
      let!(:deposit) { Invoice::Factory.new.call(booking, type: Invoices::Deposit.to_s).tap(&:save) }

      it do
        call
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
