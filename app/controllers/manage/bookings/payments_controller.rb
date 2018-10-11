module Manage
  module Bookings
    class PaymentsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :payment, through: :booking

      def index
        respond_with :manage, @booking, @payments
      end

      def new
        @payment.paid_at ||= Time.zone.now
        respond_with :manage, @booking, @payment
      end

      def show
        respond_with :manage, @booking, @payment
      end

      def edit
        respond_with :manage, @booking, @payment
      end

      def create
        @payment.save
        respond_with :manage, @booking, @payment, location: manage_booking_payments_path(@booking)
      end

      def update
        @payment.update(payment_params)
        respond_with :manage, @booking, @payment, location: manage_booking_payment_path(@booking, @payment)
      end

      def destroy
        @payment.destroy
        respond_with :manage, @booking, @payment, location: manage_booking_path(@payment.booking)
      end

      private

      def payment_params
        PaymentParams.permit(params[:payment])
      end
    end
  end
end
