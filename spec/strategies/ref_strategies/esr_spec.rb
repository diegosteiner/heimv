# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefStrategies::ESR, type: :model do
  subject(:ref_strategy) { described_class.new }

  describe '#checksum' do
    it 'calculates the checksum' do
      expect(ref_strategy.checksum('00000001000014000000000001')).to eq(8)
      expect(ref_strategy.checksum('00100000007000000000000133')).to eq(0)
    end
  end

  describe '#code_line' do
    let(:organisation) { create(:organisation, esr_participant_nr: '01-318421-1') }
    let(:invoice) { double('Invoice') }
    subject { ref_strategy.code_line(invoice) }

    before do
      expect(invoice).to receive(:organisation).and_return(organisation)
      expect(invoice).to receive(:amount_in_cents).at_least(:once).and_return(6000)
      expect(invoice).to receive(:ref).and_return('0010000140000000000018')
    end

    it { is_expected.to eq('0100000060004>000000010000140000000000018+ 013184211>') }
  end
end
