# frozen_string_literal: true

module Manage
  class BookingSerializer < Public::BookingSerializer
    association :tenant,        blueprint: Manage::TenantSerializer
    association :deadline,      blueprint: Manage::DeadlineSerializer
    association :home,          blueprint: Manage::HomeSerializer

    fields :tenant_organisation, :cancellation_reason, :invoice_address, :ref,
           :committed_request, :purpose, :approximate_headcount, :remarks

    field :links do |booking|
      {
        edit: url.edit_public_booking_url(booking.to_param, org: booking.organisation.slug),
        manage: url.manage_booking_url(booking.to_param, org: booking.organisation.slug)
      }
    end
  end
end
