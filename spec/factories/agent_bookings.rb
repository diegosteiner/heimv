FactoryBot.define do
  factory :agent_booking do
    agent { nil }
    booking { nil }
    committed_request { false }
    accepted_request { false }
  end
end
