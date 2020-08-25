# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class DefinitiveRequest < BookingStrategy::State
        include Rails.application.routes.url_helpers

        def checklist
          [
            choose_tarifs_checklist_item,
            create_contract_checklist_item,
            create_deposit_checklist_item
          ]
        end

        def self.to_sym
          :definitive_request
        end

        def relevant_time
          booking.created_at
        end

        protected

        def choose_tarifs_checklist_item
          ChecklistItem.new(:choose_tarifs, booking.booking_copy_tarifs.exists?,
                            manage_booking_tarifs_path(booking, org: booking.organisation.slug))
        end

        def create_contract_checklist_item
          ChecklistItem.new(:create_contract, booking.contract.present?,
                            manage_booking_contracts_path(booking, org: booking.organisation.slug))
        end

        def create_deposit_checklist_item
          ChecklistItem.new(:create_deposit, Invoices::Deposit.of(booking).relevant.exists?,
                            manage_booking_invoices_path(booking, org: booking.organisation.slug))
        end
      end
    end
  end
end
