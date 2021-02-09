# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentInfos::OrangePaymentSlip, type: :model do
  let(:organisation) { create(:organisation, esr_beneficiary_account: '01-318421-1') }
  let(:invoice) { double('Invoice') }
  subject(:payment_slip) { described_class.new(invoice) }

  describe '#amount_after_point' do
    subject { payment_slip.amount_after_point }
    before do
      expect(invoice).to receive(:amount).at_least(:once).and_return(263.14)
    end
    it { is_expected.to be(14) }
  end
end
