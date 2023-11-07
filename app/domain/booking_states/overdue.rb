# frozen_string_literal: true

module BookingStates
  class Overdue < Base
    MailTemplate.define(:overdue_notification, context: %i[booking], optional: true)

    include Rails.application.routes.url_helpers

    def checklist
      [
        deposits_paid_checklist_item, contract_signed_checklist_item
      ]
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :overdue
    end

    after_transition do |booking|
      booking.notifications.new(template: :overdue_notification, to: booking.tenant)&.deliver
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? && Invoices::Deposit.of(booking).kept.all?(&:paid?)
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def deposits_paid_checklist_item
      ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).kept.all?(&:paid?),
                        manage_booking_invoices_path(booking, org: booking.organisation, locale: I18n.locale))
    end

    def contract_signed_checklist_item
      ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?,
                        manage_booking_contracts_path(booking, org: booking.organisation, locale: I18n.locale))
    end
  end
end
