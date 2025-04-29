# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IBAN do
  describe '#qrr?' do
    subject { iban.qrr? }

    let(:ch_iban) { 'CH72 0900 0000 1571 4845 3' }
    let(:qr_iban) { 'CH75 3000 0002 1571 4845 3' }

    context 'with qrr iban' do
      let(:iban) { described_class.new(qr_iban) }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'without qrr iban' do
      let(:iban) { described_class.new(ch_iban) }

      it 'returns false' do
        is_expected.to be_falsey
      end
    end

    context 'with german qrr iban' do
      let(:iban) { described_class.new('DE12 3450 0000 0000 0000 3') }

      it 'returns false' do
        is_expected.to be_falsey
      end
    end
  end
end
