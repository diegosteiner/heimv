# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_transitions
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
# Indexes
#
#  index_booking_transitions_on_booking_id       (booking_id)
#  index_booking_transitions_parent_most_recent  (booking_id,most_recent) UNIQUE WHERE most_recent
#  index_booking_transitions_parent_sort         (booking_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

require 'rails_helper'

RSpec.describe BookingTransition, type: :model do
  let(:booking) { create(:booking, skip_infer_transition: true) }
  let(:transition) { build(:booking_transition, booking: booking, to_state: to_state) }
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
