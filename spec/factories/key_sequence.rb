# frozen_string_literal: true

FactoryBot.define do
  factory :key_sequence do
    key { 'test' }
    organisation
  end
end
