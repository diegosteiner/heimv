require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    BookingStateManager.new(actual).in_state?(expected.to_s)
  end
end

describe BookingState do
  let(:booking) { create(:booking, initial_state: initial_state) }

  # TODO: decouple
  let(:initial_state) { :initial }
  let(:target_state) { :new_request }

  context 'with default state' do
    it 'sets initial as default state' do
      expect(booking).to be_valid
      expect(booking).to have_state(initial_state)
      expect(booking.save).to be true
      expect(booking.state).to eq(initial_state.to_s)
    end

    it 'will not transition into invalid state' do
      expect { booking.update!(transition_to: :nonexistent) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'will transition into valid state' do
      booking.transition_to = target_state
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking).to have_state(target_state)
      expect(booking.state).to eq(target_state.to_s)
    end
  end
end
