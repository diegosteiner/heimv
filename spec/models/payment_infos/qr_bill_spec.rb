# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentInfos::QrBill, type: :model do
  subject(:qr_bill) { described_class.new(invoice) }
  let(:iban) { 'CH72 0900 0000 1571 4845 3' }
  let(:qr_iban) { 'CH75 3000 0002 1571 4845 3' }

  let(:organisation) do
    create(:organisation, :with_templates, iban:, address: "Organisation\nStrasse 1\n8000 Zürich")
  end
  let(:tenant) do
    create(:tenant, organisation:, first_name: 'Peter', last_name: 'Muster',
                    street_address: 'Teststrasse 2', zipcode: 8049, city: 'Zürich')
  end
  let(:booking) { create(:booking, organisation:, tenant:, tenant_organisation: nil) }
  let(:invoice) { create(:invoice, booking:) }

  describe '#qr_data' do
    subject { qr_bill.qr_data.values }

    before do
      allow(invoice).to receive(:amount).and_return(1255.35)
      allow(invoice).to receive(:payment_ref).and_return('00000123456789')
    end

    let(:expected_payload) do
      [
        'SPC', '0200', '1', iban.delete(' '),
        'K', 'Organisation', 'Strasse 1', '8000 Zürich', '', '', 'CH',
        '', '', '', '', '', '', '', '1255.35',
        'CHF', 'K', 'Peter Muster', 'Teststrasse 2', '8049 Zürich', '', '', 'CH',
        'SCOR', 'RF1800000123456789', '', 'EPD'
      ]
    end

    it { is_expected.to eq(expected_payload) }
  end

  describe '#formatted_ref' do
    subject { qr_bill.formatted_ref }

    before do
      allow(invoice).to receive(:payment_ref).and_return('12345678910111213')
    end

    context 'with QRR Ref' do
      let(:iban) { qr_iban }

      it { is_expected.to eq('00 00000 00123 45678 91011 12138') }
    end

    context 'with SCOR Ref' do
      it { is_expected.to eq('RF37 1234 5678 9101 1121 3') }
    end
  end
end
