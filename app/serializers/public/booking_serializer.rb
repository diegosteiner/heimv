module Public
  class BookingSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'occupancy,tenant,home'.freeze

    has_one :occupancy
    has_one :tenant
    belongs_to :home

    attributes :organisation, :cancellation_reason, :invoice_address, :ref,
               :committed_request, :purpose, :approximate_headcount, :remarks

    attribute :links do
      {
        edit: edit_manage_booking_url(object.to_param)
      }
    end
  end
end
