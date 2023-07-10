# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateSpanChecker, type: :service do
  subject(:checker) { described_class.parse(string_value) }

  describe '::parse' do
    context 'with full range' do
      let(:string_value) { '28.2.2022-31.10.2022' }

      it do
        expect(checker.begins_at).to eq(date(2022, 2, 28))
        expect(checker.ends_at).to eq(date(2022, 10, 31))
      end
    end

    context 'with no end' do
      let(:string_value) { '28.2.-' }

      it do
        expect(checker.begins_at).to eq(date(nil, 2, 28))
        expect(checker.ends_at).to eq(date(nil, nil, nil))
      end
    end

    context 'with no beginning' do
      let(:string_value) { '-31.10' }

      it do
        expect(checker.begins_at).to eq(date(nil, nil, nil))
        expect(checker.ends_at).to eq(date(nil, 10, 31))
      end
    end
  end

  describe 'Date#>=' do
    it do
      expect(date(nil, 2, 28) >= date(2000, 1, 1)).to be_truthy
    end

    it do
      expect(date(nil, 2, 28) >= date(nil, nil, 1)).to be_truthy
    end

    it do
      expect(date(nil, 2) >= date(nil, 1, 1)).to be_truthy
    end

    it do
      expect(date(2024, nil, nil) >= date(nil, 1, 1)).to be_truthy
    end

    it do
      expect(date(nil, 2, 28) >= date(nil, 3, 1)).to be_falsy
    end
  end

  describe '#overlap?' do
    let(:string_value) { '28.2.2022-31.10.2022' }
    let(:compare_value) { nil }

    subject { checker.overlap?(compare_value) }

    context 'with date inside range' do
      let(:compare_value) { Date.new(2022, 3, 12) }
      it { is_expected.to be_truthy }
    end

    context 'with date too far in the future' do
      let(:compare_value) { Date.new(2025, 3, 12) }
      it { is_expected.to be_falsy }
    end

    context 'with date too far in the past' do
      let(:compare_value) { Date.new(2020, 3, 12) }
      it { is_expected.to be_falsy }
    end

    context 'with range overlapping' do
      let(:compare_value) { Range.new(Date.new(2020, 3, 12), Date.new(2022, 3, 12)) }
      it { is_expected.to be_truthy }
    end

    context 'with range overspanning' do
      let(:compare_value) { Range.new(Date.new(2020, 3, 12), Date.new(2024, 3, 12)) }
      it { is_expected.to be_truthy }
    end

    context 'with open end' do
      let(:string_value) { '28.2.-' }
      let(:compare_value) { Date.new(2025, 3, 12) }
      it { is_expected.to be_truthy }
    end

    context 'with open start' do
      let(:string_value) { '-31.10.2023' }
      let(:compare_value) { Date.new(2021, 3, 12) }
      it { is_expected.to be_truthy }
    end
  end

  protected

  def date(*args)
    described_class::NullableDate.new(*args)
  end
end
