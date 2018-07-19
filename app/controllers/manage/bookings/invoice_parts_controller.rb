module Manage
  module Bookings
    class InvoicePartsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :invoice, through: :booking
      load_and_authorize_resource :invoice_part, through: :invoice

      def new
        respond_with :manage, @booking, @invoice, @invoice_parts
      end

      def edit
        respond_with :manage, @booking, @invoice, @invoice_part
      end

      def create
        @invoice_part.save
        respond_with :manage, @booking, @invoice, @invoice_part, location: manage_booking_invoice_path(@booking, @invoice)
      end

      def update
        @invoice_part.update(invoice_part_params)
        respond_with :manage, @booking, @invoice, @invoice_part, location: manage_booking_invoice_path(@booking, @invoice)
      end

      def destroy
        @invoice_part.destroy
        respond_with :manage, @booking, @invoice, location: manage_booking_invoice_path(@booking, @invoice)
      end

      private

      def invoice_part_params
        InvoicePartParams.permit(params.require(:invoice_part))
      end
    end
  end
end
