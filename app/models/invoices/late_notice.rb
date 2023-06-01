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
#  ref                  :string
#  sent_at              :datetime
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#
# Indexes
#
#  index_invoices_on_booking_id            (booking_id)
#  index_invoices_on_discarded_at          (discarded_at)
#  index_invoices_on_ref                   (ref)
#  index_invoices_on_supersede_invoice_id  (supersede_invoice_id)
#  index_invoices_on_type                  (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (supersede_invoice_id => invoices.id)
#

module Invoices
  class LateNotice < ::Invoice
    ::Invoice.register_subtype self

    # def suggested_invoice_parts
    #   I18n.with_locale(booking.locale) do
    #     super + Invoice.of(booking).kept.unpaid.map do |unpaid_invoice|
    #       payable_until = unpaid_invoice.payable_until && I18n.l(unpaid_invoice.payable_until.to_date)
    #       InvoiceParts::Add.new(
    #         apply: false, amount: unpaid_invoice.amount_open,
    #         label: I18n.t('invoice_parts.unpaid_invoice', payable_until: payable_until),
    #         breakdown: unpaid_invoice.to_s
    #       )
    #     end
    #   end
    # end
  end
end
