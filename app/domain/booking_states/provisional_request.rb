# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    RichTextTemplate.require_template(:provisional_request_notification, template_context: %i[booking],
                                                                         required_by: self)

    include Rails.application.routes.url_helpers

    def checklist
      [
        create_offer_checklist_item
      ]
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :provisional_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.provisional_request_deadline,
                               postponable_for: booking.organisation.settings.deadline_postponable_for,
                               remarks: booking.booking_state.t(:label))
    end

    after_transition do |booking|
      booking.notifications.new(template: :provisional_request_notification, to: booking.tenant).deliver
      booking.tentative!
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request
    end

    infer_transition(to: :overdue_request) do |booking|
      booking.deadline_exceeded?
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def create_offer_checklist_item
      checked = Invoices::Offer.of(booking).kept.exists?
      default_params = { org: booking.organisation, locale: I18n.locale }
      ChecklistItem.new(:create_offer, checked,
                        (checked &&
                          manage_booking_invoices_path(booking, **default_params)) ||
                          new_manage_booking_invoice_path(
                            booking,
                            **default_params.merge({ invoice: { type: Invoices::Offer.model_name.to_s } })
                          ))
    end
  end
end
