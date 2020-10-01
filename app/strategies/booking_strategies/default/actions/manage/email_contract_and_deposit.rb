# frozen_string_literal: true

module BookingStrategies
  class Default
    module Actions
      module Manage
        class EmailContractAndDeposit < BookingStrategy::Action
          def call!(contract = booking.contract, deposits = Invoices::Deposit.of(booking).relevant.unsent)
            notification = booking.notifications.new(from_template: :awaiting_contract, addressed_to: :tenant)
            # return false unless notification.valid?

            notification.attachments.attach(extract_attachments(booking.home, deposits, contract))
            notification.save! && contract.sent! && deposits.each(&:sent!) && notification.deliver!
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
