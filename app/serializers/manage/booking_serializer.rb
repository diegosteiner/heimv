# frozen_string_literal: true

module Manage
  class BookingSerializer < Public::BookingSerializer
    DEFAULT_INCLUDES = 'occupancies,tenant,occupancies.occupiable,home'

    association :home,        blueprint: Manage::HomeSerializer
    association :occupancies, blueprint: Manage::OccupancySerializer
    association :occupiables, blueprint: Manage::OccupiableSerializer
    association :tenant,      blueprint: Manage::TenantSerializer
    association :deadline,    blueprint: Manage::DeadlineSerializer
    association :category,    blueprint: Manage::BookingCategorySerializer
    association :contract,    blueprint: Manage::ContractSerializer
    association :usages,      blueprint: Manage::UsageSerializer

    fields :tenant_organisation, :cancellation_reason, :invoice_address, :ref, :committed_request, :tenant_id, :locale,
           :purpose_description, :approximate_headcount, :remarks, :internal_remarks

    field :operator_responsibilities do |booking|
      booking.operator_responsibilities.to_h do |operator_responsibility|
        [operator_responsibility.responsibility,
         OperatorResponsibilitySerializer.render_as_hash(operator_responsibility)]
      end
    end

    field :booking_question_responses do |booking|
      rendered_responses = booking.booking_question_responses.index_by(&:booking_question)
      rendered_responses.transform_values! { Public::BookingQuestionResponseSerializer.render_as_hash(it) }
      rendered_responses.transform_keys(&:key).merge(rendered_responses.transform_keys(&:id))
    end

    field :current_state do |booking|
      booking.booking_state.to_sym
    end

    field :links do |booking|
      {
        show: public_booking_url(booking.token, org: booking.organisation, locale: I18n.locale),
        edit: edit_public_booking_url(booking.token, org: booking.organisation, locale: I18n.locale),
        manage: manage_booking_url(booking.to_param, org: booking.organisation, locale: I18n.locale)
      }
    rescue ActionController::UrlGenerationError
      { edit: nil, manage: nil }
    end
  end
end
