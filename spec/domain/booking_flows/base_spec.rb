# frozen_string_literal: true

require 'rails_helper'

describe BookingFlows::Base do
  let(:flow_class) do
    Class.new(described_class) do
      state :initial, to: [:open_request], initial: true

      state :open_request, to: [] do
        guard_transition do |booking|
          booking.remarks == 'allowed'
        end
      end
    end
  end

  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation:) }

  before { allow(organisation).to receive(:booking_flow_class).and_return(flow_class) }

  describe 'composable state DSL' do
    it 'supports state declarations without an explicit base class' do
      booking = create(:booking, organisation:, home:, remarks: 'allowed')

      expect(booking.booking_flow).to transition_to(:open_request).from(:initial)
    end

    it 'supports per-flow guard overrides in a state block' do
      booking = create(:booking, organisation:, home:, remarks: 'blocked')

      expect(booking.booking_flow).not_to transition_to(:open_request).from(:initial)
    end
  end

  context 'when a base state class is provided' do
    let(:base_open_state_class) do
      Class.new(BookingStates::Base) do
        def self.to_sym
          :open_request
        end

        def checklist
          [:base]
        end
      end
    end

    let(:flow_class) do
      open_state = base_open_state_class

      Class.new(described_class) do
        state :initial, to: [:open_request], initial: true

        state :open_request, open_state, to: [] do
          def checklist
            [:override]
          end
        end
      end
    end

    it 'allows overriding state behavior in the flow-specific state implementation' do
      booking = create(:booking, organisation:, home:)

      booking.booking_flow.transition_to(:open_request)

      expect(booking.booking_flow.booking_state.checklist).to eq([:override])
    end
  end
end
