# == Schema Information
#
# Table name: booking_transitions
#
#  id           :bigint           not null, primary key
#  to_state     :string           not null
#  sort_key     :integer          not null
#  booking_id   :uuid             not null
#  most_recent  :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  metadata     :json
#  booking_data :json
#

require 'rails_helper'

RSpec.describe BookingTransition, type: :model do
  let(:booking) { create(:booking, skip_automatic_transition: true) }
  let(:transition) { build(:booking_transition, booking: booking, to_state: to_state) }
  let(:to_state) { :any }

  describe '#serialize_booking' do
    let(:booking_attrs) { %i[id home_id tenant_id state] }

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
