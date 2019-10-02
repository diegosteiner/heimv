require 'rails_helper'

RSpec.describe PaymentSlip, type: :model do
  let(:organisation) { create(:organisation, account_nr: '01-318421-1') }
  subject(:payment_slip) { PaymentSlip.new(invoice) }

  describe '#code' do
    subject { payment_slip.code_line }
    let(:invoice) { double('Invoice') }
    before do
      expect(invoice).to receive(:organisation).and_return(organisation)
      expect(invoice).to receive(:amount).at_least(:once).and_return(60.0)
      expect(invoice).to receive(:ref).and_return('000000010000140000000000018')
    end

    it { is_expected.to eq('0100000060004>000000010000140000000000018+ 013184211>') }
  end
end
