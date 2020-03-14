module Manage
  class BookingSerializer < Public::BookingSerializer
    has_one :tenant,   serializer: Manage::TenantSerializer
    has_one :deadline, serializer: Manage::DeadlineSerializer
    has_one :home, serializer: Manage::HomeSerializer

    attributes :tenant_organisation, :cancellation_reason, :invoice_address, :ref,
               :committed_request, :purpose, :approximate_headcount, :remarks

    attribute :links do
      {
        edit: edit_public_booking_url(object.to_param),
        manage: manage_booking_url(object.to_param)
      }
    end
  end
end
