# frozen_string_literal: true

module Manage
  class InvoiceSerializer < ApplicationSerializer
    identifier :id
    fields :type, :text, :issued_at, :payable_until, :sent_at, :booking_id,
           :amount_paid, :percentage_paid, :amount, :locale, :payment_required,
           :accounting_ref, :payment_ref
  end
end
