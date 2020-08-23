# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class PaymentOverdue < BookingStrategy::State
        include Rails.application.routes.url_helpers

        def checklist
          [
            ChecklistItem.new(:invoice_paid, booking.invoices.relevant.all?(&:paid),
                              manage_booking_invoices_path(booking, org: booking.organisation.slug))
          ]
        end

        def self.to_sym
          :payment_overdue
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
