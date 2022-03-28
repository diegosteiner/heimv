# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    actual.booking_flow.in_state?(expected.to_s)
  end
end

describe BookingStateConcern do
  let(:booking) { create(:booking, skip_infer_transition: true) }

  describe '#apply_booking_transitions' do
    it 'add an error when trying to transition into invalid state' do
      booking.transition_to = :nonexistent
      expect(booking.apply_booking_transitions).to be_falsy
      expect(booking.errors[:transition_to]).not_to be_empty
    end

    it 'transitions into valid state' do
      target_state = :open_request
      booking.transition_to = target_state
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking).to have_state(target_state)
      expect(booking.booking_state.to_s).to eq(target_state.to_s)
      expect(booking.transition_to).to be_blank
    end
  end
end
