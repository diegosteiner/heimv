class HomesController < CrudController
  def index
    respond_with @homes
  end

  def show
    breadcrumbs.add @home.to_s
    respond_with @home
  end

  def new
    breadcrumbs.add t('new')
    respond_with @home
  end

  def edit
    breadcrumbs.add @home.to_s, home_path(@home)
    breadcrumbs.add t('edit')
    respond_with @home
  end

  def create
    if @home.save
      redirect_to @home, notice: t('actions.create.success', model_name: Home.model_name.human)
    else
      render :new
    end
  end

  def update
    @home.update(home_params)
    respond_with @home
  end

  def destroy
    @home.destroy
    redirect_to homes_path, notice: t('actions.destroy.success', model_name: Home.model_name.human)
  end

  private

  def set_breadcrumbs
    super
    breadcrumbs.add Home.model_name.human(count: :other), homes_path
  end

  def home_params
    params.require(:home).permit(:name, :ref)
  end
end
