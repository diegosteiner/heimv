# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class PaymentOverdue < BookingStrategy::State
        Default.require_rich_text_template(:payment_overdue_notification, %i[booking])

        include Rails.application.routes.url_helpers

        def self.to_sym
          :payment_overdue
        end

        def checklist
          [
            ChecklistItem.new(:invoice_paid, booking.invoices.kept.all?(&:paid),
                              manage_booking_invoices_path(booking, org: booking.organisation.slug))
          ]
        end

        def self.successors
          %i[completed]
        end

        after_transition do |booking|
          booking.notifications.new(from_template: :payment_overdue_notification, addressed_to: :tenant).deliver
        end

        infer_transition(to: :completed) do |booking|
          !booking.invoices.unpaid.kept.exists?
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
