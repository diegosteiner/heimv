# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentConfirmation, type: :model do
  let(:booking) { create(:booking, notifications_enabled: true) }
  let!(:template) do
    create(:markdown_template, key: 'payment',
                               locale: I18n.locale,
                               organisation: booking.organisation,
                               body: '{{ payment.amount }}')
  end
  let(:payment) { create(:payment, booking: booking) }
  subject(:confirmation) { described_class.new(payment) }

  describe '#notification' do
    subject(:notification) { confirmation.notification }

    it do
      expect(notification.context.keys).to eq(%w[booking payment])
      expect(notification).to be_valid
      expect(notification.body).to include(payment.amount.to_s)
    end
  end
end
