# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::EmailInvoices do
  subject(:action) { described_class.new(booking:) }
  subject(:call) { described_class.call(booking:) }
  subject(:booking_after_call) do
    call
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, initial_state:) }
  let(:initial_state) { :past }
  let!(:invoice) { create(:invoice, booking:) }

  describe '#allowed?' do
    subject(:allowed) { action.allowed? }

    it { expect(allowed).to be_truthy }
  end

  describe '#call!' do
    it { expect(call.ok).to be_truthy }
    it { expect(booking_after_call).to notify(:payment_due_notification).to(:tenant) }
    it { expect(booking_after_call.notifications.last.attachments).to be_present }
    it do
      call
      expect(invoice.reload).to be_sent
    end
  end
end
