# frozen_string_literal: true

FactoryBot.define do
  factory :invoice_item, class: Invoice::Items::Add.to_s do
    usage { nil }
    amount { usage&.price || rand(50.0..1000.0) }
    label { usage.label || Faker::Commerce.product_name }
  end
end
