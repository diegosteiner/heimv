# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransitionBookingStatesJob, type: :job do
  describe '#perform' do
    subject(:transitions) { described_class.perform_now }

    it { is_expected.to eq({}) }

    context 'with deadline' do
      let(:home) { create(:home) }
      let(:booking) do
        create(:booking, initial_state: :provisional_request, home:, organisation: home.organisation,
                         committed_request: false)
      end

      before do
        booking.set_deadline(at: 15.minutes.ago, armed: true)
      end

      it { expect(transitions).to eq({ booking.id => %w[overdue_request] }) }
    end
  end
end
