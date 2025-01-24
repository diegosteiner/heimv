# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CamtService, type: :model do
  let(:invoice) { create(:invoice, organisation:) }
  let(:organisation) { create(:organisation) }
  let(:scor_ref) { 'RF42 0100 0250 9000 0789 0' }
  let(:qrr_ref) { '00 00000 00001 23456 78903' }

  subject(:camt_service) { described_class.new(organisation) }

  describe '#normalize_ref' do
    subject { described_class.normalize_ref(ref) }

    context 'with RF Reference' do
      let(:ref) { scor_ref }
      it { is_expected.to eq('1000250900007890') }
    end

    context 'with normal Reference' do
      let(:ref) { qrr_ref }
      it { is_expected.to eq('1234567890') }
    end
  end

  describe 'find_invoice_by_ref' do
    subject { camt_service.find_invoice_by_ref(ref) }

    context 'without checksum in db' do
      let(:ref) { qrr_ref }
      let!(:matching_invoice) { create(:invoice, organisation:, payment_ref: '1234567890') }
      before { create_list(:invoice, 2, organisation:) }

      it { is_expected.to eq(matching_invoice) }
    end

    context 'with checksum in db' do
      let(:ref) { qrr_ref }
      let!(:matching_invoice) { create(:invoice, organisation:, payment_ref: '12345678903') }
      before { create_list(:invoice, 2, organisation:) }

      it { is_expected.to eq(matching_invoice) }
    end

    context 'with scor_ref' do
      let(:ref) { scor_ref }
      let!(:matching_invoice) { create(:invoice, organisation:, payment_ref: '1000250900007890') }
      before { create_list(:invoice, 2, organisation:) }

      it { is_expected.to eq(matching_invoice) }
    end

    # context 'with checksum in db' do
    # context 'without checksum in db' do
  end
end
