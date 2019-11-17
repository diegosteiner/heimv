module Manage
  class TenantsController < BaseController
    load_and_authorize_resource :tenant

    before_action { breadcrumbs.add(Tenant.model_name.human(count: :other), manage_tenants_path) }
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@tenant.to_s, manage_tenant_path(@tenant)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
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
