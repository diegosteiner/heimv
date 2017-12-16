require 'rails_helper'

RSpec.describe BookingTransition, type: :model do
  let(:booking) { create(:booking) }
  let(:transition) { build(:booking_transition, booking: booking, to_state: to_state) }
  let(:to_state) { :any }

  describe '#serialize_booking' do
    let(:booking_attrs) { %i[id home_id customer_id state] }

    it do
      expect(transition.save).to be true
      expect(transition.booking_data.slice(*booking_attrs)).to eq booking.attributes.slice(*booking_attrs)
    end
  end

  describe '#update_booking_state' do
    it do
      expect(transition.save).to be true
      expect(transition.booking.state).to eq(to_state.to_s)
    end
  end
end
