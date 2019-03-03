# == Schema Information
#
# Table name: booking_transitions
#
#  id           :bigint(8)        not null, primary key
#  to_state     :string           not null
#  sort_key     :integer          not null
#  booking_id   :uuid             not null
#  most_recent  :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  metadata     :json
#  booking_data :json
#

FactoryBot.define do
  factory :booking_transition do
    to_state { booking.initial_state || :initial }
    sort_key { 0 }
    most_recent { true }
    booking
  end
end
