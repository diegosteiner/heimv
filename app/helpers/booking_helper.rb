module BookingHelper
  def customers_for_select(_booking = nil, _current_user = nil)
    Customer.all.map { |customer| ["#{customer.name}, #{customer.zipcode} #{customer.city}", customer.to_param] }
  end

  def transitions_for_select(view_model, _current_user = nil)
    view_model.allowed_transitions_for_select
  end

  def bookings_by_state_table(state, bookings, special_column= nil, help_text= nil, &block)
    safe_join([
      tag.h3(BookingStrategy::Default::ViewModel.i18n_state(state)[:label]),
      tag.span(help_text),
      render(layout: 'table', locals: { bookings: bookings, special_column: special_column }, &block)
    ])
  end
end
