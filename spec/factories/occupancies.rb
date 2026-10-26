# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id                 :uuid             not null, primary key
#  begins_at          :datetime         not null
#  color              :string
#  conflict_type      :integer          default("pending"), not null
#  ends_at            :datetime         not null
#  ignore_conflicting :boolean          default(FALSE), not null
#  linked             :boolean          default(TRUE)
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  calendar_label_id  :bigint
#  occupiable_id      :bigint           not null
#

FactoryBot.define do
  factory :occupancy do
    sequence(:begins_at) { |i| (Time.zone.now + i.month).change(hour: 9, minute: 0) }
    ends_at { (begins_at + 1.week).change(hour: 14, minute: 0) }
    conflict_type { Occupancy.conflict_types[:pending] }
    occupiable
    linked { false }

    trait :occupied do
      conflict_type { Occupancy.conflict_types[:occupied] }
    end
  end
end
