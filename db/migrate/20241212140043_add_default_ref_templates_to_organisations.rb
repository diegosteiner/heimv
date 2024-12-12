class AddDefaultRefTemplatesToOrganisations < ActiveRecord::Migration[8.0]
  def up
    Organisation.find_each do |organisation|
      organisation.booking_ref_template ||= RefBuilders::Booking::DEFAULT_TEMPLATE
      organisation.tenant_ref_template ||= RefBuilders::Tenant::DEFAULT_TEMPLATE
      organisation.invoice_ref_template ||= RefBuilders::Invoice::DEFAULT_TEMPLATE
      organisation.invoice_payment_ref_template ||= RefBuilders::InvoicePayment::DEFAULT_TEMPLATE
    end
  end
end
