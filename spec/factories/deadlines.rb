# == Schema Information
#
# Table name: deadlines
#
#  id               :bigint           not null, primary key
#  armed            :boolean          default("true")
#  at               :datetime
#  postponable_for  :integer          default("0")
#  remarks          :text
#  responsible_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  booking_id       :uuid
#  responsible_id   :bigint
#
# Indexes
#
#  index_deadlines_on_booking_id                           (booking_id)
#  index_deadlines_on_responsible_type_and_responsible_id  (responsible_type,responsible_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

FactoryBot.define do
  factory :deadline do
    at { 30.days.from_now }
    # booking { nil }
    # responsible { nil }
    postponable_for { 0 }
  end
end
