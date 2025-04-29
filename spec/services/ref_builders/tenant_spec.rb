# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::Tenant, type: :model do
  subject(:ref_builder) { described_class.new(invoice) }

  let(:organisation) { create(:organisation) }
  let(:invoice) { create(:tenant, organisation:, sequence_number: 386) }

  describe '::DEFAULT_TEPMPLATE' do
    it do
      expect(described_class::DEFAULT_TEMPLATE)
        .to eq('%<sequence_number>d')
    end
  end

  describe '#generate' do
    subject(:generate) { ref_builder.generate(template) }

    context 'with default template' do
      let(:template) { described_class::DEFAULT_TEMPLATE }

      it { is_expected.to eq('386') }
    end

    context 'with no template' do
      let(:template) { nil }

      it { is_expected.to be_nil }
    end
  end
end
