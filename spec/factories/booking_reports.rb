# == Schema Information
#
# Table name: booking_reports
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  report_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :booking_report do
    type { '' }
    booking_ids { 'MyString' }
    params { '' }
  end
end
