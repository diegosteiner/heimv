# frozen_string_literal: true

module BookingActions
  class MarkInvoicesRefunded < Base
    def invoke!(invoice_id:, current_user: nil)
      invoice = booking.organisation.invoices.find_by(id: invoice_id)
      payment = {
        invoice_id: invoice_id, amount: invoice.balance, accounting_cost_center_nr: '',
        accounting_account_nr: invoice.organisation.accounting_settings.payment_account_nr
      }

      Result.success redirect_proc: proc { new_manage_booking_payment_path(booking: invoice.booking, payment:) }
    end

    def invoke_schema
      Dry::Schema.Params do
        optional(:invoice_id).filled(:string)
      end
    end

    def invokable?(invoice_id:, current_user: nil)
      refundable_invoices.exists?(id: invoice_id)
    end

    def invokable_with(current_user: nil)
      refundable_invoices.filter_map do |invoice|
        next unless invokable?(invoice_id: invoice.id, current_user:)

        label = translate(:label_with_ref, type: invoice.model_name.human, ref: invoice.ref)
        { label:, params: { invoice_id: invoice.to_param } }
      end
    end

    def refundable_invoices
      booking.invoices.kept.refund
    end
  end
end
