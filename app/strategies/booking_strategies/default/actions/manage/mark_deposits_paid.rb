module BookingStrategies
  class Default
    module Actions
      module Manage
        class MarkDepositsPaid < BookingStrategy::Action
          def call!(unpaid_deposits = booking.invoices.deposit.unpaid)
            unless booking.contract.signed?
              booking.messages.new_from_template(:deposits_paid_message, addressed_to: :tenant)&.deliver_now
            end

            unpaid_deposits.map do |deposit|
              deposit.payments.create(amount: deposit.amount_open, paid_at: Time.zone.today)
            end
          end

          def allowed?
            booking.invoices.deposit.sent.exists? && booking.invoices.deposit.unpaid.exists?
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
