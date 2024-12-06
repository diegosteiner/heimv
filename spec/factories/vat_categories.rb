# frozen_string_literal: true

FactoryBot.define do
  factory :vat_category do
    percentage { 8.1 }
    label { 'Normalsatz' }
    organisation
    accounting_vat_code { '' }
  end
end
