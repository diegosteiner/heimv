require 'rails_helper'

describe BookingStateMachine do
  describe 'Transitions' do
    let(:booking) { create(:booking) }

    it do
      expect(booking).to be_valid
      expect(booking).to be_pending
      expect(booking.save).to be true

      booking
    end
  end

  describe '::state_enum' do
    subject { described_class.states_enum_hash }

    it do
      is_expected.to eq(pending: 'pending',
                        awaiting_preconditions: 'awaiting_preconditions',
                        reserved: 'reserved',
                        awaiting_postconditions: 'awaiting_postconditions',
                        completed: 'completed',
                        cancelled: 'cancelled')
    end
  end
end
