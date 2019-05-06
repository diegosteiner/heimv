# == Schema Information
#
# Table name: homes
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  place      :string
#  janitor    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :home do
    organisation
    name { "Pfadiheim #{Faker::Address.city}" }
    place { "#{Faker::Address.zip_code} #{Faker::Address.city}" }
    sequence(:ref) { |i| "#{name.downcase.delete('aeiuoäöü ./:;?!()')}#{i}" }
  end
end
