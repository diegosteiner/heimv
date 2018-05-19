module Manage
  class UsagesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :usage, through: :booking, shallow: true

    before_action do
      breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      breadcrumbs.add(@usage.booking, manage_booking_path(@usage.booking))
      breadcrumbs.add(Usage.model_name.human(count: :other))
    end
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@usage.to_s, manage_usage_path(@usage)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
      respond_with :manage, @usages
    end

    def show
      respond_with :manage, @usage
    end

    def edit
      respond_with :manage, @usage
    end

    def create
      @usage.save
      respond_with :manage, @usage
    end

    def update
      @usage.update(usage_params)
      respond_with :manage, @usage
    end

    def destroy
      @usage.destroy
      respond_with :manage, @usage, location: manage_booking_path(@usage.booking)
    end

    private

    def usage_params
      Params::Manage::UsageParams.new.permit(params)
    end
  end
end
