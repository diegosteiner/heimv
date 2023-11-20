# frozen_string_literal: true

module Manage
  class PagesController < BaseController
    skip_authorization_check

    def usage; end

    def flow
      @templates = booking_states.index_with do |booking_state|
        booking_state.templates.pluck(:key)
      end
      @templates[BookingStates::DefinitiveRequest] << :contract_text
      @templates[BookingStates::DefinitiveRequest] << :invoices_deposit_text
      @templates[BookingStates::AwaitingContract] = [:awaiting_contract_notification]
      @templates[BookingStates::Past] = %i[invoices_invoice_text payment_due_notification]
    end

    private

    def booking_states
      @booking_states = [
        BookingStates::UnconfirmedRequest, BookingStates::OpenRequest, BookingStates::ProvisionalRequest,
        BookingStates::OverdueRequest, BookingStates::DefinitiveRequest, BookingStates::CancelledRequest,
        BookingStates::DeclinedRequest, BookingStates::AwaitingContract,
        BookingStates::Overdue, BookingStates::Upcoming, BookingStates::UpcomingSoon, BookingStates::Active,
        BookingStates::Past, BookingStates::PaymentDue, BookingStates::PaymentOverdue, BookingStates::Completed,
        BookingStates::CancelationPending, BookingStates::Cancelled
      ]
    end
  end
end
