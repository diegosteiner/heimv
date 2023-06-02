# frozen_string_literal: true

module Manage
  class PlanBBackupsController < BaseController
    load_and_authorize_resource :plan_b_backup

    def index
      @plan_b_backups = @plan_b_backups.where(organisation: current_organisation).order(created_at: :ASC)
      respond_with :manage, @plan_b_backups.order(created_at: :ASC)
    end

    def show
      respond_with :manage, @plan_b_backup
    end
  end
end
