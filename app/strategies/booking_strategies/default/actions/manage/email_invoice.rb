# frozen_string_literal: true

module BookingStrategies
  class Default
    module Actions
      module Manage
        class EmailInvoice < BookingStrategy::Action
          Default.require_markdown_template(:payment_due_notification, %i[booking])

          def call!(invoices = booking.invoices.unsent)
            notification = booking.notifications.new(from_template: :payment_due_notification, addressed_to: :tenant)
            return unless notification

            notification.attachments.attach(invoices.map { |invoice| invoice.pdf.blob })
            notification.deliver && invoices.each(&:sent!)
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
