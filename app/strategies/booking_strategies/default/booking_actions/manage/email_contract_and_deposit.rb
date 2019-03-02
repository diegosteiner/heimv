module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class EmailContractAndDeposit < BookingStrategy::BookingAction
          def call!(contract = @booking.contract, deposits = @booking.invoices.deposit)
            @booking.messages.new_from_template(:confirmed_message)&.deliver_now do |message|
              message.attachments.attach(extract_attachments(@booking.home, deposits, contract))
            end && contract.sent! && deposits.each(&:sent!)
          end

          def allowed?
            @booking.contract.present? && !@booking.contract.sent?
          end

          def extract_attachments(home, deposits, contract)
            [
              home.house_rules.attachment&.blob,
              deposits.map { |deposit| deposit.pdf.blob },
              contract.pdf&.blob
            ].flatten.compact
          end
        end
      end
    end
  end
end
