# == Schema Information
#
# Table name: organisations
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :organisation do
    sequence(:ref) { |i| "hv-#{i}" }
    name { 'Heimverein' }
  end
end
