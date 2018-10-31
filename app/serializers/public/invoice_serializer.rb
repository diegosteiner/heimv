module Public
  class InvoiceSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'

    belongs_to :booking

    attributes :invoice_type, :text, :issued_at, :payable_until, :esr_number
  end
end
