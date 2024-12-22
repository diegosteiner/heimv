# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CamtService, type: :model do
  let(:invoice) { create(:invoice) }
  subject(:ref_service) { described_class.new(invoice.organisation) }

  describe '#normalize_ref' do
    subject { described_class.normalize_ref(ref) }

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
