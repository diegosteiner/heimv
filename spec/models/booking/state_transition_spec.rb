# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_state_transitions
#
#  id           :bigint           not null, primary key
#  booking_data :json
#  metadata     :json
#  most_recent  :boolean          not null
#  sort_key     :integer          not null
#  to_state     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#

require 'rails_helper'

RSpec.describe Booking::StateTransition do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }
  let(:transition) { build(:booking_state_transition, booking:, to_state:) }
  let(:to_state) { :any }

  describe '#serialize_booking' do
    let(:booking_attrs) { %i[id home_id tenant_id state] }

    it do
      expect(transition.save).to be true
      expect(transition.booking_data.slice(*booking_attrs)).to eq booking.attributes.slice(*booking_attrs)
    end
  end
end

:state
