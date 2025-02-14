# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                   :bigint           not null, primary key
#  amount               :decimal(, )      default(0.0)
#  amount_open          :decimal(, )
#  discarded_at         :datetime
#  issued_at            :datetime
#  locale               :string
#  payable_until        :datetime
#  payment_info_type    :string
#  payment_ref          :string
#  payment_required     :boolean          default(TRUE)
#  ref                  :string
#  sent_at              :datetime
#  sequence_number      :integer
#  sequence_year        :integer
#  status               :integer          default("draft"), not null
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#

FactoryBot.define do
  factory :invoice, class: Invoices::Invoice.sti_name do
    booking
    issued_at { 1.week.ago }
    payable_until { 3.months.from_now }
    text { Faker::Lorem.sentences }
    transient do
      skip_invoice_parts { false }
    end

    trait :sent do
      sent_at { 1.day.ago }
    end

    after(:build) do |invoice, evaluator|
      next if evaluator.skip_invoice_parts

      if evaluator.amount&.positive?
        build(:invoice_part, amount: evaluator.amount, invoice:)
      else
        build_list(:invoice_part, 3, invoice:)
      end
    end

    factory :deposit, class: Invoices::Deposit.sti_name
    factory :offer, class: Invoices::Offer.sti_name
  end
end
