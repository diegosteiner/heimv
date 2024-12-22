# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::InvoicePayment, type: :model do
  let(:organisation) { create(:organisation, esr_ref_prefix: 9999) }
  let(:invoice) { create(:invoice, organisation:, sequence_number: 386, sequence_year: 2023) }

  subject(:ref_builder) { described_class.new(invoice) }

  describe '::checksum' do
    it 'calculates the checksum' do
      expect(described_class.checksum('00000001000014000000000001')).to eq(8)
      expect(described_class.checksum('00100000007000000000000133')).to eq(0)
    end
  end

  describe '::DEFAULT_TEPMPLATE' do
    it do
      expect(described_class::DEFAULT_TEMPLATE)
        .to eq('%<prefix>s%<tenant_sequence_number>06d%<sequence_year>04d%<sequence_number>05d')
    end
  end

  describe '#generate' do
    subject(:generate) { ref_builder.generate(template) }

    context 'with default template' do
      let(:template) { described_class::DEFAULT_TEMPLATE }
      it { is_expected.to eq('9999000001202300386') }
    end

    context 'with no template' do
      let(:template) { nil }
      it { is_expected.to be_nil }
    end

    context 'with sequence_numnber ref_parts' do
      let(:template) { '%<short_sequence_year>d-%<sequence_year>d-%05<sequence_number>d' }
      it { is_expected.to eq('23-2023-00386') }
    end
  end
end
