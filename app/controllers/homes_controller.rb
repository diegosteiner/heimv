class HomesController < CrudController
  load_and_authorize_resource :home

  before_action { breadcrumbs.add(Home.model_name.human(count: :other), homes_path) }
  before_action(only: :new) { breadcrumbs.add(t('new')) }
  before_action(only: %i[show edit]) { breadcrumbs.add(@home.to_s, home_path(@home)) }
  before_action(only: :edit) { breadcrumbs.add(t('edit')) }

  def index
    respond_with @homes
  end

  def show
    respond_with @home
  end

  def new
    respond_with @home
  end

  def edit
    respond_with @home
  end

  def create
    @home.update(home_params)
    respond_with @home
  end

  def update
    @home.update(home_params)
    respond_with @home
  end

  def destroy
    @home.destroy
    respond_with @home, location: homes_path
  end

  private

  def home_params
    Params::HomeParamsService.new.call(params)
  end
end
