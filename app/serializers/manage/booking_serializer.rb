# frozen_string_literal: true

module Manage
  class BookingSerializer < Public::BookingSerializer
    association :tenant,        blueprint: Manage::TenantSerializer
    association :deadline,      blueprint: Manage::DeadlineSerializer
    association :home,          blueprint: Manage::HomeSerializer
    association :category,      blueprint: Manage::BookingCategorySerializer

    fields :tenant_organisation, :cancellation_reason, :invoice_address, :ref, :committed_request,
           :purpose_description, :approximate_headcount, :remarks, :home_id

    field :operator_responsibilities do |booking|
      booking.operator_responsibilities.to_h do |operator_responsibility|
        [
          operator_responsibility.responsibility,
          OperatorResponsibilitySerializer.render_as_hash(operator_responsibility)
        ]
      end
    end

    field :booked_extras do |booking|
      booking.booked_extras.to_h do |booked_extra|
        [
          booked_extra.bookable_extra.id,
          Public::BookableExtraSerializer.render_as_hash(booked_extra.bookable_extra)
        ]
      end
    end

    field :links do |booking|
      next { edit: nil, manage: nil } if booking.new_record?

      {
        edit: url.edit_public_booking_url(booking.token, org: booking.organisation),
        manage: url.manage_booking_url(booking.to_param, org: booking.organisation)
      }
    end
  end
end
