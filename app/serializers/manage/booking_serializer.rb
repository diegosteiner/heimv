# frozen_string_literal: true

module Manage
  class BookingSerializer < Public::BookingSerializer
    association :tenant,        blueprint: Manage::TenantSerializer
    association :deadline,      blueprint: Manage::DeadlineSerializer
    association :home,          blueprint: Manage::HomeSerializer
    association :purpose,       blueprint: Manage::BookingPurposeSerializer

    fields :tenant_organisation, :cancellation_reason, :invoice_address, :ref,
           :committed_request, :approximate_headcount, :remarks

    field :links do |booking|
      next { edit: nil, manage: nil } if booking.new_record?

      {
        edit: url.edit_public_booking_url(booking.token, org: booking.organisation.slug),
        manage: url.manage_booking_url(booking.to_param, org: booking.organisation.slug)
      }
    end
  end
end
