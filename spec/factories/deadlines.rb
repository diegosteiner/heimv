# == Schema Information
#
# Table name: deadlines
#
#  id               :bigint(8)        not null, primary key
#  at               :datetime
#  booking_id       :uuid
#  responsible_type :string
#  responsible_id   :bigint(8)
#  extendable       :integer          default(0)
#  current          :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryBot.define do
  factory :deadline do
    at { 30.days.from_now }
    # booking { nil }
    # responsible { nil }
    extendable { 0 }
  end
end
