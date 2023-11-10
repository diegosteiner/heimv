# frozen_string_literal: true

module BookingStates
  class Past < Base
    include Rails.application.routes.url_helpers

    def checklist
      [
        enter_usages_checklist_item, create_invoice_checklist_item
      ]
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :past
    end

    infer_transition(to: :payment_due) do |booking|
      invoices = Invoices::Invoice.of(booking).kept
      invoices.any?(&:sent?) || (invoices.any? && invoices.none?(&:unsettled?))
    end

    def relevant_time
      booking.ends_at
    end

    protected

    def enter_usages_checklist_item
      checked = booking.usages.any?(&:updated_after_past?) || Invoices::Invoice.of(booking).kept.exists?
      ChecklistItem.new(:create_usages, checked,
                        manage_booking_usages_path(booking, org: booking.organisation, locale: I18n.locale))
    end

    def create_invoice_checklist_item
      checked = Invoices::Invoice.of(booking).kept.exists?
      default_params = { org: booking.organisation, locale: I18n.locale }
      ChecklistItem.new(:create_invoice, checked,
                        (checked &&
                          manage_booking_invoices_path(booking, **default_params)) ||
                          new_manage_booking_invoice_path(
                            booking,
                            **default_params.merge({ invoice: { type: Invoices::Invoice.model_name.to_s } })
                          ))
    end
  end
end
