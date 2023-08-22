# frozen_string_literal: true

module Manage
  module Bookings
    class ContractsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :contract, through: :booking
      after_action :attach_files, only: %i[create update]

      def index
        @contracts = @contracts.includes(signed_pdf_attachment: :blob, pdf_attachment: :blob)
        respond_with :manage, @contracts
      end

      def show
        respond_to do |format|
          format.pdf do
            redirect_to url_for(@contract.pdf)
          end
        end
      end

      def new
        @contract = Contract::Factory.new.call(@booking)
        respond_with :manage, @booking, @contract
      end

      def edit
        respond_with :manage, @contract
      end

      def create
        @contract.valid_from = Time.zone.now
        @contract.save
        Booking::Log.log(@contract.booking, trigger: :manager, user: current_user)
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def update
        @contract.update(contract_params)
        Booking::Log.log(@contract.booking, trigger: :manager, user: current_user)
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      def destroy
        @contract.destroy
        respond_with :manage, @contract, location: manage_booking_contracts_path(@booking)
      end

      private

      def attach_files
        @contract.signed_pdf.attach(contract_params[:signed_pdf]) if contract_params[:signed_pdf].present?
      end

      def contract_params
        ContractParams.new(params.require(:contract)).permitted
      end
    end
  end
end
