# frozen_string_literal: true

module Manage
  class PagesController < BaseController
    skip_authorization_check

    def usage; end

    def flow
      @states = [
        BookingStates::UnconfirmedRequest, BookingStates::OpenRequest, BookingStates::ProvisionalRequest,
        BookingStates::OverdueRequest, BookingStates::DefinitiveRequest, BookingStates::CancelledRequest,
        BookingStates::DeclinedRequest, BookingStates::AwaitingContract,
        BookingStates::Overdue, BookingStates::Upcoming, BookingStates::UpcomingSoon, BookingStates::Active,
        BookingStates::Past, BookingStates::PaymentDue, BookingStates::PaymentOverdue, BookingStates::Completed,
        BookingStates::CancelationPending, BookingStates::Cancelled
      ]

      @rich_text_templates = rich_text_templates_by_requirer
    end

    def privacy
      @privacy_statement = DesignatedDocument.in_context(current_organisation).with_locale(I18n.locale)
                                             .privacy_statement.first
    end

    def rich_text_templates_by_requirer
      RichTextTemplate.required_templates.values.flatten.each_with_object({}) do |required, memo|
        next unless required.required_by

        memo[required.required_by] ||= []
        memo[required.required_by] << required.key
      end
    end
  end
end
