FactoryBot.define do
  factory :invoice_part, class: InvoiceParts::Add.to_s do
    invoice nil
    usage nil
    # type ''
    amount '9.99'
    text 'MyText'
    row_order_position 1
  end
end
