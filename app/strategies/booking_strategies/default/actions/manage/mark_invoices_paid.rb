module BookingStrategies
  class Default
    module Actions
      module Manage
        class MarkInvoicesPaid < BookingStrategy::Action
          def call!
            booking.invoices.unpaid.map do |invoice|
              invoice.payments.create(amount: invoice.amount_open, paid_at: Time.zone.today)
            end
          end

          def allowed?
            invoices = booking.invoices
            invoices.sent.exists? && invoices.unpaid.any? && !booking.state_machine.in_state?(:confirmed)
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
