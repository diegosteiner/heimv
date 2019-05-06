# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  organisation_id  :bigint           not null
#  name             :string
#  ref              :string
#  place            :string
#  janitor          :text
#  requests_allowed :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryBot.define do
  factory :home do
    organisation
    name { "Pfadiheim #{Faker::Address.city}" }
    place { "#{Faker::Address.zip_code} #{Faker::Address.city}" }
    sequence(:ref) { |i| "#{name.downcase.delete('aeiuoäöü ./:;?!()')}#{i}" }
  end
end
