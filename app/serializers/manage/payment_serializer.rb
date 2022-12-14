# frozen_string_literal: true

module Manage
  class PaymentSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancies,booking.tenant,booking.booking.occupancies.home'

    association :invoice, blueprint: Manage::InvoiceSerializer

    fields :paid_at, :amount, :write_off, :remarks
  end
end
