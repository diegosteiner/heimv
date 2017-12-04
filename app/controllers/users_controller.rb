class UsersController < CrudController
  before_action { breadcrumbs.add(User.model_name.human(count: :other), users_path) }
  before_action(only: :new) { breadcrumbs.add(t('new')) }
  before_action(only: %i[show edit]) { breadcrumbs.add(@user.to_s, user_path(@user)) }
  before_action(only: :edit) { breadcrumbs.add(t('edit')) }

  def index
    respond_with @users
  end

  def show
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def update
    @user.skip_reconfirmation!
    @user.update(user_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user, location: users_path
  end

  private

  def user_params
    Params::UserParamsService.new(params, current_user).process
  end
end
