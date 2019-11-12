module Manage
  module Bookings
    class ContractsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :contract, through: :booking

      def index
        respond_with :manage, @contracts
      end

      def new
        @contract.text = MarkdownTemplate[:contract_text].interpolate('booking' => @booking)
        respond_with :manage, @booking, @contract
      end

      def show
        respond_to do |format|
          # format.html
          format.pdf do
            reditect_to url_for(@contract.pdf)
          end
        end
      end

      def edit
        respond_with :manage, @contract
      end

      def create
        @contract.valid_from = Time.zone.now
        @contract.save
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def update
        @contract.update(contract_params)
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def destroy
        @contract.destroy
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      private

      def contract_params
        ContractParams.new(params.require(:contract))
      end
    end
  end
end
