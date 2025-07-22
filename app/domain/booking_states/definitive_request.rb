# frozen_string_literal: true

module BookingStates
  class DefinitiveRequest < Base
    use_mail_template(:definitive_request_notification, context: %i[booking])
    use_mail_template(:manage_definitive_request_notification, context: %i[booking], optional: true)
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:responsibilities_assigned, :tarifs_chosen, :deposit_created,
                                        :contract_created, booking:)
    end

    def self.to_sym
      :definitive_request
    end

    guard_transition(from: :open_request) do |booking|
      booking.occupancies.all? do |occupancy|
        occupancy.conflicting(%i[occupied tentative]).all? do
          it.booking&.in_state?(:open_request, :waitlisted_request)
        end
      end
    end

    guard_transition(from: :waitlisted_request) do |booking|
      booking.occupancies.all? do |occupancy|
        occupancy.conflicting(%i[occupied tentative]).all? do
          it.booking&.in_state?(:open_request, :waitlisted_request)
        end
      end
    end

    guard_transition do |booking|
      booking.committed_request && booking.tenant&.valid? && !booking.conflicting?
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.sent.none? && booking.tenant&.bookings_without_contract
    end

    infer_transition(to: :awaiting_contract) do |booking|
      booking.contracts.sent.any?
    end

    after_transition do |booking|
      OperatorResponsibility.assign(booking, :administration, :billing)
      if occupied_booking_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.update!(committed_request: true)
      booking.deadline&.clear!

      OperatorResponsibility.assign(booking, :home_handover, :home_return)

      MailTemplate.use(:manage_definitive_request_notification, booking, to: :administration, &:autodeliver!)
      MailTemplate.use(:definitive_request_notification, booking, to: :tenant, &:autodeliver!)

      booking.conflicting_bookings.each(&:apply_transitions)
    end

    def relevant_time
      booking.created_at
    end
  end
end
