module Manage
  class PaymentsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :payment, through: :booking, shallow: true

    def index
      if @booking.present?
        @payments = @booking.payments.ordered
      else
        @payments = @payments.ordered
        @payments = @payments.where(Payment.arel_table[:paid_at].gt(1.year.ago)) if params[:all].blank?
      end
      respond_with :manage, @payments
    end

    def new
      @payment.paid_at ||= Time.zone.now
      @payment.amount ||= @payment.invoice&.amount_open
      respond_with :manage, @booking, @payment
    end

    def show
      respond_with :manage, @payment
    end

    def edit
      respond_with :manage, @payment
    end

    def import
      @payments = Payment::Factory.new.from_import(payments_params)
      render 'import_done'
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
      PaymentParams.new(params[:payment])
    end

    def payments_params
      params.permit(payments: PaymentParams.permitted_keys)[:payments]
    end
  end
end
