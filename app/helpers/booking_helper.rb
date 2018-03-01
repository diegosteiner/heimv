module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def transitions_for_select(view_model, _current_user = nil)
    view_model.allowed_transitions_for_select
  end
end
