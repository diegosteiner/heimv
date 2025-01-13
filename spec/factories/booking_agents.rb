# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_agents
#
#  id                       :bigint           not null, primary key
#  address                  :text
#  code                     :string
#  email                    :string
#  name                     :string
#  provision                :decimal(, )
#  request_deadline_minutes :integer          default(14400)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint           not null
#

FactoryBot.define do
  sequence(:agent_code) { |n| "agent_#{n}" }

  factory :booking_agent do
    organisation
    name { "#{Faker::Company.name} #{Faker::Company.suffix}" }
    code { generate(:agent_code) }
    sequence(:email) { |n| "agent#{n}@heimv.test" }
    provision { (1..10).to_a.sample - 0.25 }
    address { [Faker::Address.street_address, "#{Faker::Address.zip_code} #{Faker::Address.city}"].join('\n') }
  end
end
