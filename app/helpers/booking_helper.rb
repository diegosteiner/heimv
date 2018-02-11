module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def transitions_for_select(booking, _current_user = nil)
    BookingStrategy.infer(booking).render_service.allowed_transitions_for_select
  end

  def prefered_transition_button(booking)
    # transition = BookingStrategy::StateManager.new(booking).prefered_transition
    transition = nil
    return if transition.blank?
    params = { booking: { transition_to: transition } }
    button_to manage_booking_path(booking), method: :patch, params: params, class: 'btn btn-primary' do
      t(transition, scope: 'activerecord.values.booking.state')
    end
  end
end
