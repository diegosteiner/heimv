# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefBuilders::Booking, type: :model do
  let(:organisation) { create(:organisation) }
  let(:begins_at) { DateTime.new(2030, 10, 15, 14) }
  let(:ends_at) { begins_at + 2.hours }
  let(:home) { create(:home, ref: 'P', organisation:) }
  let(:booking) { create(:booking, organisation:, begins_at:, ends_at:, home:) }
  subject(:ref_builder) { described_class.new(booking) }

  describe '#generate' do
    subject(:generate) { ref_builder.generate(template) }

    let(:template) { nil }

    context 'with default template' do
      it { is_expected.to eq('P20301015') }
    end

    context 'with special template' do
      before { create(:booking, organisation:, begins_at:, ends_at:) }
      let(:template) { 'X%<year>04d%<month>02d-%<same_day_alpha>s' }

      it { is_expected.to eq('X203010-a') }
    end

    context 'with default template and multiple bookings' do
      before do
        create(:booking, home: booking.home,  organisation:,
                         begins_at: begins_at - 4.hours, ends_at: begins_at - 2.hours)
      end

      it { is_expected.to eq('P20301015a') }
    end

    describe '#occupiable_refs' do
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
