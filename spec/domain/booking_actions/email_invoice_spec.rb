# frozen_string_literal: true

require 'rails_helper'

describe BookingActions::EmailInvoice do
  subject(:action) { described_class.new(booking, :email_invoice) }
  subject(:invoke) { action.invoke(invoice_id: invoice.id) }
  subject(:booking_after_invoke) do
    invoke
    booking.notifications.each(&:deliver)
    booking
  end

  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, :invoiced, organisation:) }
  let(:invoice) { booking.invoices.last }

  describe '#invokable?' do
    it { expect(action.invokable?(invoice_id: invoice.id)).to be_truthy }
  end

  describe '#invoke' do
    before { invoice.generate_pdf && invoice.save! }
    it { expect(invoke.success).to be_truthy }
    it { expect(booking_after_invoke).to notify(:email_invoice_notification).to(:tenant) }
    it { expect(booking_after_invoke.notifications.last.attachments).to be_present }
    it { expect(booking_after_invoke.invoices.find(invoice.id)).to be_sent }
  end
end
