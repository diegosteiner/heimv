class AddDefaultPaymentInfoToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :default_payment_info_type, :string
    add_column :organisations, :invoice_ref_template, :string, default: '%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d'
  end
end
