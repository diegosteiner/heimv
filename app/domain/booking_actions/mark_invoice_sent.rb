# frozen_string_literal: true

module BookingActions
  class MarkInvoiceSent < Base
    def invoke!(invoice_id:, current_user: nil)
      invoice = booking.organisation.invoices.find_by(id: invoice_id)
      invoice&.sent!

      Result.success redirect_proc: proc { manage_booking_invoices_path(booking: invoice.booking) }
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_id).filled(:string)
      end
    end

    def invokable?(invoice_id:, current_user: nil)
      unsent_invoices.exists?(id: invoice_id)
    end

    def invokable_with(current_user: nil)
      # Don't always show this action
      nil
      # unsent_invoices.filter_map do |invoice|
      #   next unless invokable?(invoice_id: invoice.id, current_user:)

      #   label = translate(:label_with_ref, type: invoice.model_name.human, ref: invoice.ref)
      #   { label:, params: { invoice_id: invoice.to_param } }
      # end
    end

    def unsent_invoices
      booking.invoices.kept.unsent
    end
  end
end
