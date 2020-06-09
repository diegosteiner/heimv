# == Schema Information
#
# Table name: offers
#
#  id          :bigint           not null, primary key
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid
#
# Indexes
#
#  index_offers_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#
FactoryBot.define do
  factory :offer do
    text { 'MyText' }
    valid_until { '2020-06-09 08:34:23' }
    valid_from { '2020-06-09 08:34:23' }
    booking { nil }
  end
end
