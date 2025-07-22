# frozen_string_literal: true

module BookingStates
  class ProvisionalRequest < Base
    use_mail_template(:provisional_request_notification, context: %i[booking])

    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:offer_created, booking:)
    end

    def self.to_sym
      :provisional_request
    end

    after_transition from: :definitive_request do |booking|
      booking.update(committed_request: false)
    end

    after_transition do |booking|
      booking.tentative!
      booking.create_deadline(length: booking.organisation.deadline_settings.provisional_request_deadline,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              remarks: booking.booking_state.t(:label))
      next if booking.committed_request

      MailTemplate.use(:provisional_request_notification, booking, to: :tenant, &:autodeliver!)
    end

    guard_transition do |booking|
      booking.organisation.booking_state_settings.enable_provisional_request &&
        booking.occupancies.all? do |occupancy|
          occupancy.conflicting(%i[occupied tentative]).all? do
            it.booking&.in_state?(:open_request, :waitlisted_request)
          end
        end
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
