module Manage
  class BookingSerializer < Public::BookingSerializer
    has_one :tenant,   serializer: Manage::TenantSerializer
    has_one :deadline, serializer: Manage::DeadlineSerializer

    attributes :organisation, :cancellation_reason, :invoice_address, :ref,
               :committed_request, :purpose, :approximate_headcount, :remarks

    link(:edit) { edit_manage_booking_url(object.to_param) }
  end
end
