module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def transitions_for_select(booking, _current_user = nil)
    BookingStateManager.new(booking).allowed_transitions.map do |transition|
      [t(transition, scope: 'activerecord.values.booking.state'), transition]
    end
  end

  def prefered_transition_button(booking)
    transition = BookingStateManager.new(booking).prefered_transition
    return unless transition.present?
    params = { booking: { transition_to: transition } }
    button_to booking_path(booking), method: :patch, params: params, class: 'btn btn-primary' do
      t(transition, scope: 'activerecord.values.booking.state')
    end
  end
end
