# frozen_string_literal: true

module Manage
  class InvoicesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :invoice, through: :booking, shallow: true

    def index
      @invoices = if @booking.present?
                    @booking.invoices
                  elsif params[:all].present?
                    @invoices
                  else
                    @invoices.kept.unpaid
                  end
      @invoices = @invoices.includes(:organisation, :payments).ordered.with_attached_pdf
      respond_with :manage, @invoices
    end

    def new
      @invoice = Invoices::Factory.new.call(@booking, invoice_params)
      @suggested_invoice_parts = InvoiceParts::Factory.new.suggest(@invoice)
      respond_with :manage, @booking, @invoice
    end

    def show
      # @invoice.touch if Rails.env.development?
      respond_to do |format|
        format.html
        format.pdf do
          redirect_to url_for(@invoice.pdf)
        end
      end
    end

    def edit
      @suggested_invoice_parts = InvoiceParts::Factory.new.suggest(@invoice)
      respond_with :manage, @invoice
    end

    def create
      @invoice.save
      respond_with :manage, @invoice, location: manage_booking_invoices_path(@invoice.booking)
    end

    def update
      @invoice.update(invoice_params) unless @invoice.discarded?
      respond_with :manage, @invoice, location: manage_booking_invoices_path(@invoice.booking)
    end

    def destroy
      @invoice.discard!
      respond_with :manage, @invoice, location: manage_booking_path(@invoice.booking)
    end

    private

    def invoice_params
      InvoiceParams.new(params[:invoice]).permitted
    end
  end
end
