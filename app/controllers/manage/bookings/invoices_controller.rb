module Manage
  module Bookings
    class InvoicesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :invoice, through: :booking

      def index
        respond_with :manage, @booking, @invoices
      end

      def new
        @invoice = Invoice.new({ booking: @booking, invoice_type: :invoice }.merge(invoice_params || {}))
        @invoice.text ||= MarkdownTemplate["#{@invoice.invoice_type}_invoice_text"] % @booking
        @invoice.payable_until ||= 30.days.from_now unless @invoice_type == :deposit
        @suggested_invoice_parts = InvoiceParts::Factory.new.suggest(@invoice)
        respond_with :manage, @booking, @invoice
      end

      def show
        respond_to do |format|
          format.html
          format.pdf do
            redirect_to url_for(@invoice.pdf)
          end
        end
      end

      def edit
        @suggested_invoice_parts = InvoiceParts::Factory.new.suggest(@invoice)
        respond_with :manage, @booking, @invoice
      end

      def create
        @invoice.save
        respond_with :manage, @booking, @invoice, location: manage_booking_invoices_path(@booking)
      end

      def update
        @invoice.update(invoice_params)
        respond_with :manage, @booking, @invoice, location: manage_booking_invoice_path(@booking, @invoice)
      end

      def destroy
        @invoice.destroy
        respond_with :manage, @booking, @invoice, location: manage_booking_path(@invoice.booking)
      end

      private

      def invoice_params
        InvoiceParams.permit(params[:invoice])
      end
    end
  end
end
