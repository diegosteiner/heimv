# frozen_string_literal: true

module Manage
  class QuoteSerializer < ApplicationSerializer
    identifier :id
    fields :text, :issued_at, :valid_until, :sent_at, :booking_id, :amount, :locale, :ref

    association :items, blueprint: Manage::InvoiceItemSerializer
  end
end
