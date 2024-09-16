# frozen_string_literal: true

module Manage
  class InvoiceSerializer < ApplicationSerializer
    identifier :id
    fields :type, :text, :issued_at, :payable_until, :ref, :sent_at, :booking_id,
           :amount_paid, :percentage_paid, :amount, :locale, :vat, :payment_required
  end
end
