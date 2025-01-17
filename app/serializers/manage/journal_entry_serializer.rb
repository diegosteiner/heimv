# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    identifier :id
    fields :date, :ref, :currency, :soll_amount, :haben_amount, :booking_id, :invoice_id, :payment_id
  end
end
