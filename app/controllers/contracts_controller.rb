class ContractsController < ApplicationController
  before_action :set_contract, only: %i[show edit update destroy]
  before_action :set_booking
  before_action :authenticate_user!
  before_action :set_breadcrumbs
  after_action :verify_authorized

  def index
    @contracts = @booking.contracts
    authorize Contract
  end

  def show
    breadcrumbs.add @contract.to_s
  end

  def new
    authorize Contract
    breadcrumbs.add t('new')
    @contract = Contract.new(params[:contract])
  end

  def edit
    breadcrumbs.add @contract.to_s, booking_contract_path(@booking, @contract)
    breadcrumbs.add t('edit')
  end

  def create
    authorize Contract
    @contract = Contract.new(contract_params.merge(booking: @booking))

    if @contract.save
      redirect_to @contract, notice: t('actions.create.success', model_name: Contract.model_name.human)
    else
      render :new
    end
  end

  def update
    if @contract.update(contract_params)
      redirect_to @contract, notice: t('actions.update.success', model_name: Contract.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @contract.destroy
    redirect_to contracts_path, notice: t('actions.destroy.success', model_name: Contract.model_name.human)
  end

  private

  def set_booking
    @booking = @contract&.booking || Booking.find(params[:booking_id])
  end

  def set_contract
    @contract = Contract.find(params[:id])
    authorize @contract
  end

  def set_breadcrumbs
    super
    breadcrumbs.add Booking.model_name.human(count: :other), bookings_path
    breadcrumbs.add @booking.to_s, booking_path(@booking)
    breadcrumbs.add Contract.model_name.human(count: :other)
  end

  def contract_params
    params.require(:contract).permit(:sent_at, :signed_at, :title, :text)
  end
end
