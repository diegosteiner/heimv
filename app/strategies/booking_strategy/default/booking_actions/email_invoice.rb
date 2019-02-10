module BookingStrategy
  class Default
    module BookingActions
      class EmailInvoice < BookingStrategy::Base::BookingActions::Base
        def call(booking)
          booking.messages.new_from_template(:payment_due_message)&.deliver_now do |message|
            message.attachments.attach(booking.invoices.active.map { |invoice| invoice.pdf.blob })
          end
        end

        def self.available_on?(booking)
          booking.invoices.unsent.any?
        end
      end
    end
  end
end
