module Manage
  class PaymentsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :payment, through: :booking, shallow: true

    def index
      @payments = @booking.payments if @booking.present?
      respond_with :manage, @payments
    end

    def new
      @payment.paid_at ||= Time.zone.now
      respond_with :manage, @booking, @payment
    end

    def show
      respond_with :manage, @payment
    end

    def edit
      respond_with :manage, @payment
    end

    def import
      @payments = payments_params.values.map do |payment_params|
        Payment.new(payment_params) unless payment_params.delete(:_destroy) == '1'
      end

      redirect_to(manage_payments_path) if @payments.all?(&:save)
    end

    def new_import
      @payments = params[:camt_file].presence && Payment::Factory.new.from_camt_file(params[:camt_file])

      if @payments.present?
        render 'import'
      else
        respond_with :manage, @payments
      end
    end

    def create
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

    def payment_params
      PaymentParams.permit(params[:payment])
    end

    def payments_params
      params.permit(payments: [PaymentParams.permitted_keys + %i[_destroy]])[:payments]
    end
  end
end
