module Manage
  class TenantsController < BaseController
    load_and_authorize_resource :tenant

    def index
      @tenants = @tenants.ordered
      respond_with :manage, @tenants
    end

    def show
      respond_with :manage, @tenant
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
      respond_with :manage, @tenant, location: manage_tenants_path
    end

    private

    def tenant_params
      TenantParams.new(params[:tenant])
    end
  end
end
