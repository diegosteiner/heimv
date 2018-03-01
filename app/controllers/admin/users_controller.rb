module Admin
  class UsersController < BaseController
    load_and_authorize_resource :user

    before_action { breadcrumbs.add(User.model_name.human(count: :other), admin_users_path) }
    before_action(only: :new) { breadcrumbs.add(t(:'new')) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@user.to_s, admin_user_path(@user)) }
    before_action(only: :edit) { breadcrumbs.add(t(:'edit')) }

    def index
      respond_with :admin, @users
    end

    def show
      respond_with :admin, @user
    end

    def edit
      respond_with :admin, @user
    end

    def update
      @user.skip_reconfirmation!
      @user.update(user_params)
      respond_with :admin, @user
    end

    def destroy
      @user.destroy
      respond_with :admin, @user, location: admin_users_path
    end

    private

    def user_params
      Params::Admin::UserParams.new.call(params)
    end
  end
end
