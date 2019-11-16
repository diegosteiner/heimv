module BookingStrategies
  class Default
    module Actions
      module Manage
        class EmailContractAndDeposit < BookingStrategy::Action
          def call!(contract = booking.contract, deposits = booking.invoices.deposit)
            message = booking.messages.new_from_template(:confirmed_message, addressed_to: :tenant)
            return false unless message

            message.attachments.attach(extract_attachments(booking.home, deposits, contract))
            message.save && contract.sent! && deposits.each(&:sent!) && message.deliver_now
          end

          def allowed?
            booking.contract.present? && !booking.contract.sent?
          end

          def extract_attachments(home, deposits, contract)
            [
              home.house_rules.attachment&.blob,
              deposits.map { |deposit| deposit.pdf.blob },
              contract.pdf&.blob
            ].flatten.compact
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
