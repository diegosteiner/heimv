# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::Booking, type: :model do
  subject(:ref_builder) { described_class.new(booking) }

  let(:organisation) { create(:organisation, booking_ref_template: template) }
  let(:template) { described_class::DEFAULT_TEMPLATE }
  let(:begins_at) { DateTime.new(2030, 10, 15, 14) }
  let(:ends_at) { begins_at + 2.hours }
  let(:home) { create(:home, ref: 'P', organisation:) }
  let(:booking) do
    build(:booking, organisation:, begins_at:, ends_at:, home:, sequence_number: 420, sequence_year: 2024)
  end

  describe '#generate' do
    subject(:generate) { ref_builder.generate(template) }

    context 'with default template' do
      it { is_expected.to eq('P20301015') }
    end

    context 'with no template' do
      let(:template) { nil }

      it { is_expected.to be_nil }
    end

    context 'with date ref_parts' do
      before { create(:booking, organisation:, begins_at:, ends_at:) }

      let(:template) { 'X%<year>04d%<month>02d-%02<day>d%<same_ref_alpha>s' }

      it { is_expected.to eq('X203010-15a') }
    end

    context 'with other ref_parts' do
      before { create(:booking, organisation:, begins_at:, ends_at:) }

      let(:template) { '%<sequence_year>d-%04<sequence_number>d' }

      it { is_expected.to eq('2024-0420') }
    end

    context 'with default template and multiple bookings' do
      before do
        create(:booking, home:, organisation:, begins_at: begins_at - 4.hours, ends_at: begins_at - 2.hours)
      end

      it { is_expected.to eq('P20301015a') }
    end

    describe 'with occupiable ref_parts' do
      let(:template) { '%<occupiable_refs>s-%<year>04d%<month>02d' }
      let(:occupiables) do
        %w[A B C].map do |ref|
          create(:occupiable, home:, organisation:, ref:, occupiable: true)
        end
      end
      let(:booking) do
        create(:booking, organisation:, begins_at:, ends_at: begins_at + 2.hours, home:, occupiables:)
      end

      it { is_expected.to eq('ABC-203010') }
    end
  end
end
