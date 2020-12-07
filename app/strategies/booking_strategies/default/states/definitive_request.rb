# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class DefinitiveRequest < BookingStrategy::State
        Default.require_markdown_template(:definitive_request_notification, %i[booking])
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

        guard_transition do |booking|
          booking.tenant.present? && booking.tenant.valid?
        end

        def self.successors
          %i[cancelation_pending awaiting_contract]
        end

        infer_transition(to: :awaiting_contract) do |booking|
          booking.contracts.sent.any?
        end

        after_transition do |booking|
          booking.occupancy.tentative!
          booking.update!(timeframe_locked: true, editable: false)
          booking.deadline&.clear
          booking.notifications.new(from_template: :definitive_request_notification, addressed_to: :tenant).deliver
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
          ChecklistItem.new(:create_deposit, Invoices::Deposit.of(booking).kept.exists?,
                            manage_booking_invoices_path(booking, org: booking.organisation.slug))
        end
      end
    end
  end
end
