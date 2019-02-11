module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class EmailInvoice < BookingStrategy::BookingAction
          def call!
            @booking.messages.new_from_template(:payment_due_message)&.deliver_now do |message|
              message.attachments.attach(@booking.invoices.active.map { |invoice| invoice.pdf.blob })
            end
          end

          def allowed?
            @booking.invoices.unsent.any?
          end
        end
      end
    end
  end
end
