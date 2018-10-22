module Manage
  class PaymentsController < BaseController
    load_and_authorize_resource :payment

    def index
      respond_with :manage, @payments
    end

    def new
      respond_with :manage, @payments
    end

    def show
      respond_with :manage, @payment
    end

    def edit
      respond_with :manage, @payment
    end

    def create
      @payments = params[:camt_file].presence && Payment::Factory.new.from_camt_file(params[:camt_file])
      render 'new'
    end

    def update
      @payment.update(payment_params)
      respond_with :manage, @payment, location: manage_payment_path(@payment)
    end

    def destroy
      @payment.destroy
      respond_with :manage, @payment, location: manage_payments_path(@payment.booking)
    end

    private

    def payment_params
      PaymentParams.permit(params[:payment])
    end
  end
end
