# frozen_string_literal: true

module BookingStrategies
  class Default
    module Actions
      module Manage
        class EmailContractAndDeposit < BookingStrategy::Action
          def call!(contract = booking.contract, deposits = Invoices::Deposit.of(booking).relevant.unsent)
            message = booking.messages.new(from_template: :awaiting_contract_message, addressed_to: :tenant)
            return false unless message.valid?

            message.attachments.attach(extract_attachments(booking.home, deposits, contract))
            message.save! && contract.sent! && deposits.each(&:sent!) && message.deliver!
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
