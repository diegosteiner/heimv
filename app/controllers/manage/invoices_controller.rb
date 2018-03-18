module Manage
  class InvoicesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :invoice, through: :booking, shallow: true

    before_action do
      breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      breadcrumbs.add(@invoice.booking, manage_booking_path(@invoice.booking))
      breadcrumbs.add(Invoice.model_name.human(count: :other))
    end
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@invoice.to_s, manage_invoice_path(@invoice)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    # def index
    #   respond_with :manage, @invoices
    # end

    def show
      respond_with :manage, @invoice
    end

    def edit
      respond_with :manage, @invoice
    end

    def create
      @invoice.save
      respond_with :manage, @invoice
    end

    def update
      @invoice.update(invoice_params)
      respond_with :manage, @invoice
    end

    def destroy
      @invoice.destroy
      respond_with :manage, @invoice, location: manage_booking_path(@invoice.booking)
    end

    private

    def invoice_params
      Params::Manage::InvoiceParams.new.call(params)
    end
  end
end
