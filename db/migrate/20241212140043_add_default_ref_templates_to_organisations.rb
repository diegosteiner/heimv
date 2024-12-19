class AddDefaultRefTemplatesToOrganisations < ActiveRecord::Migration[8.0]
  def up
    Organisation.find_each do |organisation|
      organisation.instance_eval do
        self.booking_ref_template = RefBuilders::Booking::DEFAULT_TEMPLATE if booking_ref_template.blank?
        self.tenant_ref_template = RefBuilders::Tenant::DEFAULT_TEMPLATE if tenant_ref_template.blank?
        self.invoice_ref_template = RefBuilders::Invoice::DEFAULT_TEMPLATE if invoice_ref_template.blank?
        self.invoice_payment_ref_template = RefBuilders::InvoicePayment::DEFAULT_TEMPLATE if invoice_payment_ref_template.blank?
        save!
      end
    end
  end
end
