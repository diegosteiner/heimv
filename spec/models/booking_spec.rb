require 'rails_helper'

describe Booking, type: :model do
  describe '#state_transition' do
    let(:booking) { build(:booking) }

    it do
      expect(booking).to be_valid
      expect(booking).to be_pending
      expect(booking.save).to be true
      expect(booking).to be_pending

      expect { booking.completed! }.to raise_error(ActiveRecord::RecordInvalid)

      booking.state = :awaiting_preconditions
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking).to be_awaiting_preconditions

      booking.cancelled!
      expect(booking).to be_cancelled
    end
  end
end
