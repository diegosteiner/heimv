class CustomersController < CrudController
  before_action { breadcrumbs.add(Customer.model_name.human(count: :other), customers_path) }
  before_action(only: :new) { breadcrumbs.add(t('new')) }
  before_action(only: %i[show edit]) { breadcrumbs.add(@customer.to_s, customer_path(@customer)) }
  before_action(only: :edit) { breadcrumbs.add(t('edit')) }

  def index
    respond_with @customers
  end

  def show
    respond_with @customer
  end

  def edit
    respond_with @customer
  end

  def create
    @customer.update(customer_params)
    respond_with @customer
  end

  def update
    @customer.update(customer_params)
    respond_with @customer
  end

  def destroy
    @customer.destroy
    respond_with @customer, location: customers_path
  end

  private

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :street_address, :zipcode, :city)
  end
end
