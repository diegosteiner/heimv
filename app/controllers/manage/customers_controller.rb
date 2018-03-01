module Manage
  class CustomersController < BaseController
    load_and_authorize_resource :customer

    before_action { breadcrumbs.add(Customer.model_name.human(count: :other), manage_customers_path) }
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@customer.to_s, manage_customer_path(@customer)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
      respond_with :manage, @customers
    end

    def show
      respond_with :manage, @customer
    end

    def edit
      respond_with :manage, @customer
    end

    def create
      @customer.save
      respond_with :manage, @customer
    end

    def update
      @customer.update(customer_params)
      respond_with :manage, @customer
    end

    def destroy
      @customer.destroy
      respond_with :manage, @customer, location: manage_customers_path
    end

    private

    def customer_params
      Params::Manage::CustomerParams.new.call(params)
    end
  end
end
