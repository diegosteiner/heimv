# frozen_string_literal: true

module Manage
  class JournalEntryBatchSerializer < ApplicationSerializer
    identifier :id
    fields :date, :ref, :currency, :booking_id, :invoice_id, :payment_id, :trigger
  end
end
