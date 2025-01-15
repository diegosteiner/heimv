# frozen_string_literal: true

module Manage
  class InvoicePartsController < BaseController
    load_and_authorize_resource :invoice
    load_and_authorize_resource :invoice_part, through: :invoice
    before_action :set_booking, only: %i[edit update create]

    def new
      respond_with :manage, @invoice, @invoice_parts
    end

    def edit
      respond_with :manage, @invoice, @invoice_part
    end

    def create
      @invoice_part.save && @invoice_part.invoice.recalculate!
      respond_with :manage, @invoice, @invoice_part, location: manage_invoice_path(@invoice)
    end

    def update
      @invoice_part.update(invoice_part_params) && @invoice_part.invoice.recalculate!
      respond_with :manage, @invoice, @invoice_part, location: manage_invoice_path(@invoice)
    end

    def destroy
      @invoice_part.destroy && @invoice_part.invoice.recalculate!
      respond_with :manage, @invoice, location: manage_invoice_path(@invoice)
    end

    private

    def set_booking
      @booking = @invoice&.booking
    end

    def invoice_part_params
      InvoicePartParams.new(params.require(:invoice_part)).permitted
    end
  end
end
