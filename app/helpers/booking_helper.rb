module BookingHelper
  def tenants_for_select(_booking = nil, _current_user = nil)
    Tenant.all.map { |tenant| ["#{tenant.name}, #{tenant.zipcode} #{tenant.city}", tenant.to_param] }
  end

  def transitions_for_select(view_model, _current_user = nil)
    view_model.allowed_transitions_for_select
  end

  def bookings_by_state_table(state, bookings, special_column = nil, help_text = nil, &block)
    safe_join([
                tag.h3(BookingStrategy::Default::ViewModel.i18n_state(state)[:label]),
                tag.span(help_text),
                render(layout: 'table', locals: { bookings: bookings, special_column: special_column }, &block)
              ])
  end

  def tenant_address(tenant, phone: true, email: true)
    tag.address(class: 'mb-0') do
      safe_join([
        tenant.address_lines,
        (link_to(tenant.phone, "tel:#{tenant.phone}") if phone && tenant.phone),
        (mail_to(tenant.email, tenant.email) if email)
      ].reject(&:blank?), '<br>'.html_safe)
    end
  end
end
