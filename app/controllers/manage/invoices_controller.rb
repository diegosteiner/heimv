# frozen_string_literal: true

module Manage
  class InvoicesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :invoice, through: :booking, shallow: true
    before_action :set_filter, only: :index

    def index
      @invoices = @invoices.where(booking: { organisation: current_organisation })
                           .includes(:organisation, :payments).ordered.with_attached_pdf
      @invoices = @invoices.where(booking: @booking) if @booking.present?
      @invoices = @filter.apply(@invoices, cached: false) if @filter.any? && @booking.blank?

      respond_with :manage, @invoices
    end

    def show
      @booking = @invoice.booking
      respond_to do |format|
        format.html
        format.pdf do
          redirect_to url_for(@invoice.pdf)
        end
      end
    end

    def new
      @invoice = Invoice::Factory.new.call(@booking, invoice_params)
      respond_with :manage, @booking, @invoice
    end

    def edit
      @booking = @invoice.booking
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
      @invoice.discarded? ? @invoice.destroy : @invoice.discard!
      respond_with :manage, @invoice, location: manage_booking_path(@invoice.booking)
    end

    private

    def set_filter
      default_filter_params = { paid: false }
      @filter = Invoice::Filter.new(default_filter_params.merge(invoice_filter_params || {}))
    end

    def invoice_filter_params
      params[:filter]&.permit(%w[issued_at_after issued_at_before payable_until_after payable_until_before
                                 invoice_type paid])
    end

    def invoice_params
      InvoiceParams.new(params[:invoice]).permitted
    end
  end
end
