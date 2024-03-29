# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    actual.booking_flow.in_state?(expected.to_s)
  end
end

describe BookingStateConcern do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }
  let(:target_state) { :open_request }

  describe '#apply_transitions' do
    it 'add an error when trying to transition into invalid state' do
      # booking.skip_infer_transitions = true
      expect(booking.apply_transitions(:nonexistent)).to be_falsy
      expect(booking.errors[:transition_to]).not_to be_empty
    end

    it 'transitions into valid state' do
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking.apply_transitions(target_state)).not_to be_falsy
      expect(booking).to have_state(target_state)
      expect(booking.booking_state.to_s).to eq(target_state.to_s)
    end
  end
end
