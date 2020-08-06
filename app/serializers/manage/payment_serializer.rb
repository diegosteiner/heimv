# frozen_string_literal: true

module Manage
  class PaymentSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'

    belongs_to :booking, serializer: Manage::BookingSerializer
    belongs_to :invoice, serializer: Manage::InvoiceSerializer

    attributes :paid_at, :amount, :write_off, :remarks
  end
end
