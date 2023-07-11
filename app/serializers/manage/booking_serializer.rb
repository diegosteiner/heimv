# frozen_string_literal: true

module Manage
  class BookingSerializer < Public::BookingSerializer
    DEFAULT_INCLUDES = 'occupancies,tenant,occupancies.occupiable,home'

    association :home,          blueprint: Manage::HomeSerializer
    association :occupancies,   blueprint: Manage::OccupancySerializer
    association :occupiables,   blueprint: Manage::OccupiableSerializer
    association :tenant,        blueprint: Manage::TenantSerializer
    association :deadline,      blueprint: Manage::DeadlineSerializer
    association :category,      blueprint: Manage::BookingCategorySerializer

    fields :tenant_organisation, :cancellation_reason, :invoice_address, :ref, :committed_request, :tenant_id, :locale,
           :id, :purpose_description, :approximate_headcount, :remarks, :home_id, :occupiable_ids, :bookable_extra_ids

    field :operator_responsibilities do |booking|
      booking.responsibilities.transform_values do |operator_responsibility|
        OperatorResponsibilitySerializer.render_as_hash(operator_responsibility)
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

    field :booking_question_responses do |booking|
      booking.booking_question_responses.to_h do |booking_question_response|
        [
          booking_question_response.booking_question_id,
          Public::BookingQuestionResponseSerializer.render_as_hash(booking_question_response)
        ]
      end
    end

    field :current_state do |booking|
      booking.booking_state.to_sym
    end

    field :links do |booking|
      {
        edit: url.edit_public_booking_url(booking.token, org: booking.organisation, locale: I18n.locale),
        manage: url.manage_booking_url(booking.to_param, org: booking.organisation, locale: I18n.locale)
      }
    rescue ActionController::UrlGenerationError
      { edit: nil, manage: nil }
    end
  end
end
