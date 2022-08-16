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

FactoryBot.define do
  factory :booking_state_transition, class: 'Booking::StateTransition' do
    to_state { booking.initial_state || :initial }
    sort_key { 0 }
    most_recent { true }
    booking
  end
end
