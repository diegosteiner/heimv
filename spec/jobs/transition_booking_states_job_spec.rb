# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransitionBookingStatesJob, type: :job do
  describe '#perform' do
    subject(:transitions) { described_class.perform_now }

    it { is_expected.to eq({}) }

    context 'with deadlines' do
      let(:home) { create(:home) }
      let(:booking) do
        create(:booking, initial_state: :provisional_request, home: home, organisation: home.organisation)
      end

      before do
        booking.deadline&.clear
        booking.deadlines.create(at: 15.minutes.ago)
      end

      it { expect(transitions).to eq({ booking.id => %w[definitive_request overdue_request] }) }
    end
  end
end
