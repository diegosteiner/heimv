module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class MarkDepositsPaid < BookingStrategy::BookingAction

          def call!
            if !@booking.contract.signed?
              @booking.messages.new_from_template(:deposits_paid_message)&.deliver_now
            end

            @booking.invoices.deposit.unpaid.map do |deposit|
              deposit.payments.create(amount: deposit.amount_open, paid_at: Time.zone.today)
            end
          end

          def allowed?
            @booking.invoices.deposit.sent.exists? && @booking.invoices.deposit.unpaid.exists?
          end
        end
      end
    end
  end
end
