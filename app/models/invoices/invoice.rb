# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  amount_open        :decimal(, )
#  discarded_at       :datetime
#  issued_at          :datetime
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
#  index_invoices_on_booking_id    (booking_id)
#  index_invoices_on_discarded_at  (discarded_at)
#  index_invoices_on_ref           (ref)
#  index_invoices_on_type          (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

module Invoices
  class Invoice < ::Invoice
    def suggested_invoice_parts
      deposits = Invoices::Deposit.of(booking).kept
      super + [InvoiceParts::Add.new(
        apply: new_record?, label: Invoices::Deposit.model_name.human,
        amount: - deposits.sum(&:amount_paid)
      )]
    end
  end
end
