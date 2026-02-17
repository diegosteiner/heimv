# == Schema Information
#
# Table name: seasons
#
#  id                          :bigint           not null, primary key
#  begins_at                   :datetime         not null
#  discarded_at                :datetime
#  ends_at                     :datetime         not null
#  label_i18n                  :jsonb
#  max_bookings                :integer
#  max_occupied_days           :integer
#  public_occupancy_visibility :integer          not null
#  status                      :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  organisation_id             :bigint           not null
#
FactoryBot.define do
  factory :season do
    organisation { nil }
    label_i18n { "" }
    begins_at { "2026-02-03 15:58:56" }
    ends_at { "2026-02-03 15:58:56" }
    occupancy_visibility { 1 }
    bookable { false }
    max_bookings { 1 }
    max_occupied_days { 1 }
  end
end
