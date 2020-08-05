# frozen_string_literal: true

module BookingStrategies
  class Default
    module Actions
      module Manage
        class EmailInvoice < BookingStrategy::Action
          def call!(invoices = booking.invoices.unsent)
            booking.messages.new(from_template: :payment_due_message, addressed_to: :tenant)&.tap do |message|
              message.attachments.attach(invoices.map { |invoice| invoice.pdf.blob })
            end&.deliver && invoices.each(&:sent!)
          end

          def allowed?
            booking.invoices.unsent.any? && !booking.state_machine.in_state?(:definitive_request)
          end

          def booking
            context.fetch(:booking)
          end
        end
      end
    end
  end
end
