# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )      default(0.0)
#  balance                   :decimal(, )
#  discarded_at              :datetime
#  issued_at                 :datetime
#  items                     :jsonb
#  locale                    :string
#  payable_until             :datetime
#  payment_info_type         :string
#  payment_ref               :string
#  payment_required          :boolean          default(TRUE)
#  ref                       :string
#  sent_at                   :datetime
#  sequence_number           :integer
#  sequence_year             :integer
#  status                    :integer
#  text                      :text
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#  supersede_invoice_id      :bigint
#

FactoryBot.define do
  factory :quote do
    booking
    issued_at { 1.week.ago }
    valid_until { 3.months.from_now }
    text { Faker::Lorem.sentences }
    transient do
      skip_items { false }
    end

    after(:build) do |invoice, evaluator|
      next if evaluator.skip_items

      invoice.items = if evaluator.amount&.positive?
                        build_list(:invoice_item, 1, amount: evaluator.amount)
                      else
                        build_list(:invoice_item, 3)
                      end
    end
  end
end
