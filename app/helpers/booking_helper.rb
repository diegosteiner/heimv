module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def states_for_select(booking, _current_user = nil)
    BookingStateManager.new(booking).allowed_transitions.map do |transition|
      [t(transition, scope: 'activerecord.values.booking.state'), transition]
    end
  end
end
