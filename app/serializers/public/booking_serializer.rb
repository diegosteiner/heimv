module Public
  class BookingSerializer < ApplicationSerializer
    has_one :occupancy
    has_one :tenant
    belongs_to :home

    attributes :organisation, :cancellation_reason, :invoice_address,
               :committed_request, :purpose, :approximate_headcount, :remarks
  end
end
