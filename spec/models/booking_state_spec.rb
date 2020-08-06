# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    actual.state_machine.in_state?(expected.to_s)
  end
end

describe BookingState do
  let(:booking) { create(:booking, skip_automatic_transition: true) }

  describe '#valid?' do
    it 'add an error when trying to transition into invalid state' do
      booking.transition_to = :nonexistent
      expect(booking).not_to be_valid
      expect(booking.errors[:transition_to]).not_to be_empty
    end

    it 'does not transition into invalid state' do
      expect { booking.update!(transition_to: :nonexistent) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  skip do
    describe '#state_transition' do
      it 'transitions into valid state' do
        booking.transition_to = target_state
        expect(booking).to be_valid
        expect(booking.save).to be true
        expect(booking).to have_state(target_state)
        expect(booking.state).to eq(target_state.to_s)
      end
    end
  end
end
