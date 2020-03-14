# == Schema Information
#
# Table name: booking_agents
#
#  id              :bigint           not null, primary key
#  address         :text
#  code            :string
#  email           :string
#  name            :string
#  provision       :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           default("1"), not null
#
# Indexes
#
#  index_booking_agents_on_code             (code)
#  index_booking_agents_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
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
