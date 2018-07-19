FactoryBot.define do
  factory :usage do
    tarif
    used_units '9.99'
    remarks 'Test'
    booking { tarif.booking }
  end
end
