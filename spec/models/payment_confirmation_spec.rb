# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentConfirmation, type: :model do
  subject(:confirmation) { described_class.new(payment) }

  let(:booking) { create(:booking, notifications_enabled: true) }
  let!(:template) do
    create(:mail_template, key: :payment_confirmation_notification,
                           organisation: booking.organisation,
                           body: '{{ payment.amount }}')
  end
  let(:payment) { create(:payment, booking:, invoice: nil) }

  before do
    allow(RichTextTemplate).to receive(:template_key_valid?).and_return(true)
  end

  describe '#notification' do
    subject(:notification) { confirmation.notification }

    it do
      expect(notification.template_context.keys).to include(*%i[booking payment])
      expect(notification).to be_valid
      expect(notification.body).to include(payment.amount.to_s)
    end
  end
end
