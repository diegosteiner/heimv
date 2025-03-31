# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    use_mail_template(:provisional_request_notification, context: %i[booking])

    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:offer_created, booking:)
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :provisional_request
    end

    after_transition from: :definitive_request do |booking|
      booking.update(committed_request: false)
    end

    after_transition do |booking|
      booking.create_deadline(length: booking.organisation.deadline_settings.provisional_request_deadline,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              remarks: booking.booking_state.t(:label))
      booking.tentative!
      next if booking.committed_request

      mail = MailTemplate.use(:provisional_request_notification, booking, to: :tenant)
      mail&.autodeliver!
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request
    end

    infer_transition(to: :overdue_request) do |booking|
      booking.deadline&.exceeded?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
