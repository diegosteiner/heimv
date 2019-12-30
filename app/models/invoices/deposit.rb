# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  deleted_at         :datetime
#  issued_at          :datetime
#  paid               :boolean          default(FALSE)
#  payable_until      :datetime
#  payment_info_type  :string
#  print_payment_slip :boolean          default(FALSE)
#  ref                :string
#  sent_at            :datetime
#  text               :text
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#
# Indexes
#
#  index_invoices_on_booking_id  (booking_id)
#  index_invoices_on_ref         (ref)
#  index_invoices_on_type        (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

module Invoices
  class Deposit < ::Invoice
    ::Invoice.scope :deposit, -> { where(type: Invoices::Deposit.to_s) }
  end
end
