# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class Past < BookingStrategy::State
        include Rails.application.routes.url_helpers

        def checklist
          [
            enter_usages_checklist_item, create_invoice_checklist_item
          ]
        end

        def self.to_sym
          :past
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
          ChecklistItem.new(:create_invoice, Invoices::Invoice.of(booking).relevant.exists?,
                            manage_booking_invoices_path(booking, org: booking.organisation.slug))
        end
      end
    end
  end
end
