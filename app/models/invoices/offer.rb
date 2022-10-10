# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )      default(0.0)
#  amount_open       :decimal(, )
#  discarded_at      :datetime
#  issued_at         :datetime
#  payable_until     :datetime
#  payment_info_type :string
#  ref               :string
#  sent_at           :datetime
#  text              :text
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  booking_id        :uuid
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
  class Offer < ::Invoice
    ::Invoice.register_subtype self

    def amount_open
      0
    end

    def payment_info
      nil
    end
  end
end
