
module Manage
  module Bookings
  class ContractsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :contract, through: :booking

    layout false, only: :show

    before_action do
      breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      breadcrumbs.add(@booking, manage_booking_path(@booking))
      breadcrumbs.add(Contract.model_name.human(count: :other), manage_booking_contracts_path)
    end
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@contract.to_s, manage_booking_contract_path(@booking, @contract)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
      respond_with :manage, @contracts
    end

    def show
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Your_filename",
          show_as_html: true
          # template: "manage/contracts/show"
          # layout: 'pdf.html'
        end
  end
    end

    def edit
      respond_with :manage, @contract
    end

    def create
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
      Params::Manage::ContractParams.new.permit(params)
    end
  end
end
end
