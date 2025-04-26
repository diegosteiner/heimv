# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::BookingState do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:booking_condition) { described_class.new(compare_value:, organisation:, compare_operator:) }
    let(:organisation) { create(:organisation) }
    let(:booking) { create(:booking, organisation:, initial_state: :open_request, committed_request: false) }
    let(:compare_value) { 'open_request' }
    let(:compare_operator) { '=' }

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with non matching state' do
      let(:booking) { create(:booking, organisation:) }

      it { is_expected.to be_falsy }
    end

    context 'with matching state' do
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end

    context 'with previous matching state' do
      let(:compare_operator) { '>' }

      before do
        booking.update(committed_request: true)
        booking.apply_transitions(%i[provisional_request definitive_request])
      end

      it { expect(booking.booking_state.to_sym).to eq(:definitive_request) }
      it { is_expected.to be_truthy }
    end
  end
end
