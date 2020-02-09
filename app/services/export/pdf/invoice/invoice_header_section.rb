module Export
  module Pdf
    class Invoice
      class InvoiceHeaderSection < Base::Section
        def initialize(invoice)
          @invoice = invoice
        end

        def render
          text "#{::Booking.human_attribute_name(:ref)}: #{@invoice.booking.ref}", size: 9
          render_date(::Invoice.human_attribute_name(:sent_at), @invoice.sent_at || Time.zone.today)
          return unless @invoice.payable_until

          render_date(::Invoice.human_attribute_name(:payable_until), @invoice.payable_until.to_date)
        end

        protected

        def render_date(label, date)
          text "#{label}: #{I18n.l(date)}", size: 9
        end
      end
    end
  end
end
