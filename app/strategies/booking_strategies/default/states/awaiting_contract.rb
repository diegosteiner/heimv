# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class AwaitingContract < BookingStrategy::State
        include Rails.application.routes.url_helpers

        def checklist
          [
            deposits_paid_checklist_item, contract_signed_checklist_item
          ]
        end

        def self.to_sym
          :awaiting_contract
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
