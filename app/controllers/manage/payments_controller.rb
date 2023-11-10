# frozen_string_literal: true

module Manage
  class PaymentsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :payment, through: :booking, shallow: true

    def index
      if @booking.present?
        @payments = @booking.payments.ordered
      else
        @payments = @payments.joins(:booking).where(booking: { organisation: current_organisation }).ordered
        @payments = @payments.recent if params[:all].blank?
      end
      respond_with :manage, @payments
    end

    def show
      respond_with :manage, @payment
    end

    def new
      @payment.paid_at ||= Time.zone.now
      @payment.amount ||= @payment.invoice&.amount_open
      respond_with :manage, @booking, @payment
    end

    def edit
      respond_with :manage, @payment
    end

    def import
      @payments = Payment::Factory.new(current_organisation).from_import(payments_params)
      render 'import_done'
    end

    def new_import
      @bookings = bookings_for_import
      @invoices = invoices_for_import
      @payments = params[:camt_file].presence &&
                  Payment::Factory.new(current_organisation).from_camt_file(params[:camt_file])

      render 'import' if @payments.present?
    rescue CamtParser::Errors::BaseError, Nokogiri::SyntaxError => e
      flash.now[:alert] = t('.exception', errors: e.message)
    end

    def create
      @payment.booking = @payment.booking || @booking
      @payment.save
      respond_with :manage, @payment, location: manage_booking_payments_path(@payment.booking)
    end

    def update
      @payment.update(payment_params)
      respond_with :manage, @payment, location: manage_payment_path(@payment)
    end

    def destroy
      @payment.destroy
      respond_with :manage, @payment, location: manage_booking_payments_path(@payment.booking)
    end

    private

    def bookings_for_import
      current_organisation.bookings.accessible_by(current_ability).where(concluded: false).order(ref: :ASC)
    end

    def invoices_for_import
      current_organisation.invoices.accessible_by(current_ability).kept.unsettled.order(ref: :ASC)
    end

    def payment_params
      PaymentParams.new(params[:payment]).permitted
    end

    def payments_params
      params.permit(payments: PaymentParams.permitted_keys)[:payments]
    end
  end
end
