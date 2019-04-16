module BookingStrategies
  class Default
    module Actions
      module Manage
        class MarkDepositsPaid < BookingStrategy::Action
          def call!
            @booking.messages.new_from_template(:deposits_paid_message)&.deliver_now unless @booking.contract.signed?

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
