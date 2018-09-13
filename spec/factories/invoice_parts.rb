FactoryBot.define do
  factory :invoice_part, class: InvoiceParts::Add.to_s do
    invoice { nil }
    usage { nil }
    # type ''
    amount { '9.99' }
    label { 'MyText' }
    label_2 { 'MyText' }
  end
end
