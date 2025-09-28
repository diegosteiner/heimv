# frozen_string_literal: true

module Manage
  class PaymentsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :payment, through: :booking, shallow: true
    before_action :set_filter, only: :index

    def index
      @payments = if @booking.present?
                    @booking.payments.ordered
                  else
                    @payments.joins(:booking).where(booking: { organisation: current_organisation }).ordered
                  end
      @payments = @filter.apply(@payments)
      respond_with :manage, @payments
    end

    def show
      respond_with :manage, @payment
    end

    def new
      @payment = Payment::Factory.new(current_organisation).build(payment_params)
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
                  CamtService.new(current_organisation).payments_from_file(params[:camt_file])

      render 'import' if @payments.present?
    rescue CamtParser::Errors::BaseError, Nokogiri::SyntaxError => e
      flash.now[:alert] = t('.exception', errors: e.message)
    end

    def create
      @payment.booking = @payment.booking || @booking
      @payment.save && write_booking_log
      respond_with :manage, @payment, location: -> { manage_booking_payments_path(@payment.booking) }
    end

    def update
      @payment.update(payment_params)
      respond_with :manage, @payment, location: -> { manage_payment_path(@payment) }
    end

    def destroy
      @payment.discarded? ? @payment.destroy : @payment.discard!
      respond_with :manage, @payment, location: -> { manage_booking_payments_path(@payment.booking) }
    end

    private

    def set_filter
      default_filter_params = { paid_at_after: (@booking.blank? ? 3.months.ago : nil) }.with_indifferent_access
      @filter = Payment::Filter.new(default_filter_params.merge(payment_filter_params || {}))
    end

    def payment_filter_params
      params[:filter]&.permit(%w[ref paid_at_before paid_at_after sort])
    end

    def bookings_for_import
      current_organisation.bookings.accessible_by(current_ability).where(concluded: false).order(ref: :ASC)
    end

    def write_booking_log
      Booking::Log.log(@payment.booking, trigger: :manager, action: Payment, user: current_user)
    end

    def invoices_for_import
      current_organisation.invoices.accessible_by(current_ability).kept.outstanding.order(ref: :ASC)
    end

    def payment_params
      PaymentParams.new(params[:payment]).permitted
    end

    def payments_params
      params.permit(payments: PaymentParams.permitted_keys)[:payments]
    end
  end
end
