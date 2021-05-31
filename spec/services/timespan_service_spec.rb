# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimespanService, type: :model do
  describe '::parse' do
    subject { described_class.parse(value) }

    context 'with string' do
      let(:value) { '1w 5d 2h 4m' }

      it { is_expected.to eq(1_044_240) }
    end

    context 'with int' do
      let(:value) { 200 }

      it { is_expected.to eq(200) }
    end

    context 'with other' do
      let(:value) { nil }

      it { is_expected.to eq(nil) }
    end
  end
end
