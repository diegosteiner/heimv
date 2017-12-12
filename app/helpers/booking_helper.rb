module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def states_for_select(booking, _current_user = nil)
    booking.state_machine.allowed_or_current_transitions.map do |transition|
      [transition, t(transition, scope: 'activerecord.values.booking.state')]
    end
  end
end
