class ContractsController < ApplicationController
  before_action :set_contract, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @contracts = Contract.all
    authorize Contract
  end

  def show
    breadcrumbs.add @contract.to_s
  end

  def new
    authorize Contract
    breadcrumbs.add t('new')
    @contract = Contract.new(contract_params)
  end

  def edit
    breadcrumbs.add @contract.to_s, contract_path(@contract)
    breadcrumbs.add t('edit')
  end

  def create
    authorize Contract
    @contract = Contract.new(contract_params)

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
    def set_contract
      @contract = Contract.find(params[:id])
      authorize @contract
    end

    def set_breadcrumbs
      super
      breadcrumbs.add Contract.model_name.human(count: :other), contracts_path
    end

    def contract_params
      params.require(:contract).permit(:booking_id, :sent_at, :signed_at, :title, :text)
    end
end
