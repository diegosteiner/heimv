# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    templates << MailTemplate.define(:provisional_request_notification, context: %i[booking])

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
      booking.tentative!
      next if booking.committed_request

      mail = MailTemplate.use(:provisional_request_notification, booking, to: :tenant)
      mail&.attach :accepted_documents if booking.state_transitions.last(2).map(&:to_state) == [OpenRequest.to_s, to_s]
      mail&.autodeliver
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
