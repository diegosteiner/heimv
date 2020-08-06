# frozen_string_literal: true

module Manage
  class InvoiceSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'

    belongs_to :booking, serializer: Manage::BookingSerializer

    attributes :type, :text, :issued_at, :payable_until, :ref, :sent_at
  end
end
