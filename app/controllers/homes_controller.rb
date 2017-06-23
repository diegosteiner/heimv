class HomesController < ApplicationController
  before_action :set_home, only: %i[show edit update destroy]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @homes = Home.all
    authorize Home
  end

  def show
    breadcrumbs.add @home.to_s
  end

  def new
    authorize Home
    breadcrumbs.add t('new')
    @home = Home.new
  end

  def edit
    breadcrumbs.add @home.to_s, home_path(@home)
    breadcrumbs.add t('edit')
  end

  def create
    authorize Home
    @home = Home.new(home_params)

    if @home.save
      redirect_to @home, notice: t('actions.create.success', model_name: Home.model_name.human)
    else
      render :new
    end
  end

  def update
    if @home.update(home_params)
      redirect_to @home, notice: t('actions.update.success', model_name: Home.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @home.destroy
    redirect_to homes_path, notice: t('actions.destroy.success', model_name: Home.model_name.human)
  end

  private

  def set_home
    @home = Home.find(params[:id])
    authorize @home
  end

  def set_breadcrumbs
    super
    breadcrumbs.add Home.model_name.human(count: :other), homes_path
  end

  def home_params
    params.require(:home).permit(:name, :ref)
  end
end
