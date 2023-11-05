# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingRefService, type: :model do
  subject(:ref_strategy) { described_class.new }

  describe '#generate' do
    subject(:ref) { ref_strategy.generate(booking, template) }

    let(:template) { nil }
    let(:begins_at) { DateTime.new(2030, 10, 15, 14) }
    let(:organisation) { create(:organisation) }
    let(:home) { create(:home, ref: 'P', organisation:) }
    let(:booking) do
      create(:booking, organisation:, begins_at:, ends_at: begins_at + 2.hours, home:)
    end

    context 'with default template' do
      it { is_expected.to eq('P20301015') }
    end

    context 'with special template' do
      let(:template) { 'X%<year>04d%<month>02d-%<same_month_count>d' }

      it { is_expected.to eq('X203010-1') }
    end

    context 'with default template and multiple bookings' do
      before do
        create(:booking, home: booking.home, begins_at: begins_at - 4.hours, ends_at: begins_at - 2.hours,
                         organisation:)
      end

      it { is_expected.to eq('P20301015a') }
    end
  end
end
