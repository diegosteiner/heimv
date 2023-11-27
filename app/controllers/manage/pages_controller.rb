# frozen_string_literal: true

module Manage
  class PagesController < BaseController
    skip_authorization_check

    def usage; end

    def flow
      @booking_states = current_organisation.booking_flow_class.state_classes.values
      @templates = @booking_states.index_with do |booking_state|
        booking_state.templates.pluck(:key)
      end
      @templates[BookingStates::DefinitiveRequest] << :contract_text
      @templates[BookingStates::DefinitiveRequest] << :invoices_deposit_text
      @templates[BookingStates::AwaitingContract] = [:awaiting_contract_notification]
      @templates[BookingStates::Past] = %i[invoices_invoice_text payment_due_notification]
    end
  end
end
