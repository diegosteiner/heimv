module Manage
  module Bookings
    class ContractsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :contract, through: :booking

      layout false, only: :show

      # before_action do
      #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      #   breadcrumbs.add(@booking, manage_booking_path(@booking))
      #   breadcrumbs.add(Contract.model_name.human(count: :other), manage_booking_contracts_path)
      # end
      # before_action(only: :new) { breadcrumbs.add(t(:new)) }
      # before_action(only: %i[show edit]) { breadcrumbs.add(@contract.to_s,
      # manage_booking_contract_path(@booking, @contract)) }
      # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

      def index
        respond_with :manage, @contracts
      end

      def new
        @contract.text = MarkdownTemplate.find_by(key: :new, interpolatable_type: :Contract)&.body
        respond_with :manage, @booking, @contract
      end

      def show
        respond_to do |format|
          format.html
          format.pdf do
            pdf = Pdf::Contract.new(@contract).build
            send_data(pdf.render, filename: @contract.filename, content_type: 'application/pdf')
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
        ContractParams.permit(params.require(:contract))
      end
    end
  end
end
