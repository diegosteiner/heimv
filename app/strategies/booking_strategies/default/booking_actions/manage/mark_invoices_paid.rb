module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class MarkInvoicesPaid < BookingStrategy::BookingAction

          def call!
            @booking.invoices.unpaid.map do |invoice|
              invoice.payments.create(amount: invoice.amount_open, paid_at: Time.zone.today)
            end
          end

          def allowed?
            invoices = @booking.invoices
            invoices.sent.exists? && invoices.unpaid.any? && !@booking.state_machine.in_state?(:confirmed)
          end
        end
      end
    end
  end
end
