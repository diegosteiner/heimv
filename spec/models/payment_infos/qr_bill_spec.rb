# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentInfos::QrBill, type: :model do
  let(:organisation) { create(:organisation, iban: '01-318421-1', address: "Organisation\nTeststrasse 1\n8000 Zürich") }
  let(:tenant) do
    create(:tenant, organisation: organisation, first_name: 'Peter', last_name: 'Muster',
                    street_address: 'Teststrasse 2', zipcode: 8049, city: 'Zürich')
  end
  let(:booking) { create(:booking, organisation: organisation, tenant: tenant) }
  let(:invoice) { create(:invoice, booking: booking) }
  subject(:qr_bill) { described_class.new(invoice) }

  describe '#qr_data' do
    before do
      allow(invoice).to receive(:amount).and_return(255.35)
      allow(invoice).to receive(:ref).and_return('00000123456789')
    end
    let(:expected_payload) do
      [
        'SPC', '0200', '1', '01-318421-1',
        'K', 'Organisation', 'Teststrasse 1', '8000 Zürich', '', '', 'CH',
        '', '', '', '', '', '', '', '255.35',
        'CHF', 'K', 'Peter Muster', 'Teststrasse 2', '8049 Zürich CH', '', '', 'CH',
        'SCOR', 'RF1800000123456789', '', 'EPD'
      ]
    end
    subject { qr_bill.qr_data.values }
    it { is_expected.to eq(expected_payload) }
  end
end
