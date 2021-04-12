# frozen_string_literal: true

module BookingStates
  class Past < BookingState
    include Rails.application.routes.url_helpers

    def checklist
      [
        enter_usages_checklist_item, create_invoice_checklist_item
      ]
    end

    def self.to_sym
      :past
    end

    def self.successors
      %i[completed payment_due]
    end

    infer_transition(to: :payment_due) do |booking|
      Invoices::Invoice.of(booking).kept.sent.exists?
    end

    def relevant_time
      booking.occupancy.ends_at
    end

    protected

    def enter_usages_checklist_item
      ChecklistItem.new(:create_usages, booking.usages_entered?,
                        manage_booking_usages_path(booking, org: booking.organisation.slug))
    end

    def create_invoice_checklist_item
      checked = Invoices::Invoice.of(booking).kept.exists?
      default_params = { org: booking.organisation.slug, locale: I18n.locale }
      ChecklistItem.new(:create_invoice, checked,
                        checked &&
                          manage_booking_invoices_path(booking, **default_params) ||
                          new_manage_booking_invoice_path(
                            booking,
                            **default_params.merge({ invoice: { type: Invoices::Invoice.model_name.to_s } })
                          ))
    end
  end
end
