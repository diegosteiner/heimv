# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class Overdue < BookingStrategy::State
        Default.require_markdown_template(:overdue_notification, %i[booking])

        include Rails.application.routes.url_helpers

        def checklist
          [
            deposits_paid_checklist_item, contract_signed_checklist_item
          ]
        end

        def self.to_sym
          :overdue
        end

        def self.successors
          %i[cancelation_pending upcoming]
        end

        after_transition do |booking|
          booking.occupancy.occupied!
          booking.notifications.new(from_template: :overdue_notification, addressed_to: :tenant)&.deliver
        end

        infer_transition(to: :upcoming) do |booking|
          booking.contracts.signed.any? && Invoices::Deposit.of(booking).relevant.all?(&:paid)
        end

        def relevant_time
          booking.deadline&.at
        end

        protected

        def deposits_paid_checklist_item
          ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).relevant.all?(&:paid),
                            manage_booking_invoices_path(booking, org: booking.organisation.slug))
        end

        def contract_signed_checklist_item
          ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?,
                            manage_booking_contracts_path(booking, org: booking.organisation.slug))
        end
      end
    end
  end
end
