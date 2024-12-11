# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::InvoicePayment, type: :model do
  let(:invoice) { create(:invoice) }
  subject(:ref_service) { described_class.new(invoice) }

  describe '::checksum' do
    it 'calculates the checksum' do
      expect(described_class.checksum('00000001000014000000000001')).to eq(8)
      expect(described_class.checksum('00100000007000000000000133')).to eq(0)
    end
  end
end
