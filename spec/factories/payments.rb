# == Schema Information
#
# Table name: payments
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  data       :jsonb
#  paid_at    :date
#  ref        :string
#  remarks    :text
#  write_off  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :uuid
#  invoice_id :bigint
#
# Indexes
#
#  index_payments_on_booking_id  (booking_id)
#  index_payments_on_invoice_id  (invoice_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (invoice_id => invoices.id)
#

FactoryBot.define do
  factory :payment do
    amount { '9.99' }
    paid_at { '2018-10-11' }
    data { 'MyText' }
    confirm { false }
  end
end
