module BookingHelper
  def tenants_for_select(_booking = nil, _current_user = nil)
    Tenant.all.map { |tenant| ["#{tenant.name}, #{tenant.zipcode} #{tenant.city}", tenant.to_param] }
  end

  def homes_for_select
    Home.all.map { |home| [home.to_s, home.to_param] }
  end

  def state_translation; end

  def transition_translation(to:, from: nil)
    @organisation.booking_strategy.t([from, to].join('-->'), scope: :transition, default: nil) ||
      @organisation.booking_strategy.t("-->#{to}", scope: :transition, default: nil) ||
      {}
  end

  def tenant_address(tenant, phone: true, email: true)
    tag.address(class: 'mb-0') do
      safe_join([
        tenant.address_lines,
        (link_to(tenant.phone, "tel:#{tenant.phone}") if phone && tenant.phone),
        (mail_to(tenant.email, tenant.email) if email)
      ].reject(&:blank?), tag.br)
    end
  end
end
