# frozen_string_literal: true

module Manage
  class InvoiceSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'

    association :booking, blueprint: Manage::BookingSerializer

    fields :type, :text, :issued_at, :payable_until, :ref, :sent_at
  end
end
