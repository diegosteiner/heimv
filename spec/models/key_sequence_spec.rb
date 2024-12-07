# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeySequence, type: :model do
  let(:organisation) { key_sequence.organisation }
  let(:key) { 'test' }
  subject(:key_sequence) { create(:key_sequence, value: 10, key:) }

  describe '#lease!' do
    subject(:lease!) { key_sequence.lease! }

    it { expect { lease! }.to(change { key_sequence.reload.value }.by(1)) }
    it { is_expected.to eq(11) }
  end

  describe '::key' do
    subject { organisation.key_sequences.key(key, year:) }
    let(:year) { nil }

    it { is_expected.to eq(key_sequence) }

    context 'with not existing key_sequence' do
      let(:year) { 2023 }
      it { is_expected.to have_attributes(year:, key:) }
    end

    context 'with not existing key_sequence' do
      let(:year) { true }
      it { is_expected.to have_attributes(year: Time.zone.today.year, key:) }
    end
  end
end
