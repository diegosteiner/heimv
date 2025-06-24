# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#  amount                    :decimal(, )
#  data                      :jsonb
#  paid_at                   :date
#  ref                       :string
#  remarks                   :text
#  write_off                 :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  camt_instr_id             :string
#  invoice_id                :bigint
#

FactoryBot.define do
  factory :payment do
    invoice
    amount { '9.99' }
    paid_at { '2018-10-11' }
    confirm { false }
  end
end
