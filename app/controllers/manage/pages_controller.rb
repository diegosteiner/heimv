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

      @rich_text_templates = rich_text_templates_for_help
    end

    private

    def rich_text_templates_by_requirer
      rich_text_templates = Hash.new { |hash, key| hash[key] = [] }
      RichTextTemplate.required_templates.values.flatten.each_with_object(rich_text_templates) do |required, memo|
        next unless required.required_by

        memo[required.required_by] << required.key
      end
    end

    def rich_text_templates_for_help
      rich_text_templates_by_requirer.tap do |rich_text_templates|
        rich_text_templates[BookingStates::DefinitiveRequest] << :contract_text
        rich_text_templates[BookingStates::DefinitiveRequest] << :invoices_deposit_text
        rich_text_templates[BookingStates::AwaitingContract] << :awaiting_contract_notification
        rich_text_templates[BookingStates::Past] << :invoices_invoice_text
        rich_text_templates[BookingStates::Past] << :payment_due_notification
      end
    end
  end
end
