# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::Manage::EmailInvoices do
  subject(:action) { described_class.new(booking) }
  subject(:invoke) { action.invoke }
  subject(:booking_after_invoke) do
    invoke
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, :invoiced, organisation:) }
  let!(:invoice) { booking.invoices.last }

  describe '#allowed?' do
    subject(:allowed) { action.allowed? }

    it { expect(allowed).to be_truthy }
  end

  describe '#invoke' do
    before { invoice.generate_pdf && invoice.save! }
    it { expect(invoke.success).to be_truthy }
    it { expect(booking_after_invoke).to notify(:payment_due_notification).to(:tenant) }
    it { expect(booking_after_invoke.notifications.last.attachments).to be_present }
    it do
      invoke
      expect(invoice.reload).to be_sent
    end
  end
end
