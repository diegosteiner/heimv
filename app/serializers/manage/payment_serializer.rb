# frozen_string_literal: true

module Manage
  class PaymentSerializer < ApplicationSerializer
    identifier :id
    association :invoice, blueprint: Manage::InvoiceSerializer

    fields :paid_at, :amount, :write_off, :remarks
  end
end
