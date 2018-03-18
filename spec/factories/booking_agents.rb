FactoryBot.define do
  sequence(:agent_code) { |n| "agent_#{n}" }

  factory :booking_agent do
    name { "#{Faker::Company.name} #{Faker::Company.suffix}" }
    code { generate(:agent_code) }
    email { Faker::Internet.email }
  end
end
