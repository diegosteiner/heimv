# == Schema Information
#
# Table name: booking_agents
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :string
#  email      :string
#  address    :text
#  provision  :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  sequence(:agent_code) { |n| "agent_#{n}" }

  factory :booking_agent do
    organisation
    name { "#{Faker::Company.name} #{Faker::Company.suffix}" }
    code { generate(:agent_code) }
    sequence(:email) { |n| "agent#{n}@heimverwaltung.example.com" }
    provision { (1..10).to_a.sample - 0.25 }
    address { [Faker::Address.street_address, "#{Faker::Address.zip_code} #{Faker::Address.city}"].join('\n') }
  end
end
