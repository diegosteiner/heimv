# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::Invoice, type: :model do
  subject(:ref_builder) { described_class.new(invoice) }

  let(:organisation) { create(:organisation, esr_ref_prefix: 9999) }
  let(:invoice) { create(:invoice, organisation:, sequence_number: 386, sequence_year: 2023) }

  describe '::DEFAULT_TEPMPLATE' do
    it do
      expect(described_class::DEFAULT_TEMPLATE)
        .to eq('%<short_sequence_year>02d%<sequence_number>04d')
    end
  end

  describe '#generate' do
    subject(:generate) { ref_builder.generate(template) }

    context 'with default template' do
      let(:template) { described_class::DEFAULT_TEMPLATE }

      it { is_expected.to eq('230386') }
    end

    context 'with no template' do
      let(:template) { nil }

      it { is_expected.to be_nil }
    end
  end
end
