# frozen_string_literal: true

module Manage
  class InvoiceSerializer < ApplicationSerializer
    fields :type, :text, :issued_at, :payable_until, :ref, :sent_at, :booking_id,
           :amount_paid, :percentage_paid
  end
end
