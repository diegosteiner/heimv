# frozen_string_literal: true

module Manage
  class TenantsController < BaseController
    load_and_authorize_resource :tenant
    before_action :set_filter, only: :index

    def index
      @tenants = @tenants.where(organisation: current_organisation).ordered
      @tenants = @filter.apply(@tenants) if @filter.any?
      respond_with :manage, @tenants
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: TenantSerializer.render(@tenant) }
      end
    end

    def edit
      respond_with :manage, @tenant
    end

    def create
      @tenant.organisation = current_organisation
      @tenant.save
      respond_with :manage, @tenant
    end

    def update
      @tenant.update(tenant_params)
      respond_with :manage, @tenant
    end

    def destroy
      @tenant.destroy
      respond_with :manage, @tenant, location: -> { manage_tenants_path }
    end

    private

    def tenant_params
      TenantParams.new(params[:tenant])
    end

    def set_filter
      @filter = Tenant::Filter.new(params[:filter]&.permit(:q).to_h)
    end
  end
end
