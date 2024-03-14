# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceRefService, type: :model do
  subject(:ref_strategy) { described_class.new }

  describe '#checksum' do
    it 'calculates the checksum' do
      expect(ref_strategy.checksum('00000001000014000000000001')).to eq(8)
      expect(ref_strategy.checksum('00100000007000000000000133')).to eq(0)
    end
  end

  describe '#normalize_ref' do
    subject { ref_strategy.normalize_ref(ref) }

    context 'with RF Reference' do
      let(:ref) { 'RF42 0100 0250 9000 0789 0' }

      it { is_expected.to eq('000000000001000250900007890') }
    end

    context 'with normal Reference' do
      let(:ref) { '0100 0250 9000 0789 0' }

      it { is_expected.to eq('000000000001000250900007890') }
    end
  end
end
