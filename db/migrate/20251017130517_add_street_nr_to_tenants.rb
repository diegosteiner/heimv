# frozen_string_literal: true

class AddStreetNrToTenants < ActiveRecord::Migration[8.0]
  def change
    change_table :tenants, bulk: true do |t|
      t.string :street_nr
      t.string :street
    end
    rename_column :bookings, :invoice_address, :unstructured_invoice_address
    add_column :organisations, :qr_bill_creditor_address, :jsonb

    change_table :bookings, bulk: true do |t|
      t.jsonb :invoice_address
      t.boolean :use_invoice_address, default: false, null: false
      t.string :bookings, :invoice_cc
    end

    reversible do |direction|
      direction.up do
        migrate_organisations
        migrate_tenants
        migrate_invoice_addresses
      end
    end
  end

  private

  def migrate_tenants
    Tenant.find_each do |tenant|
      street, _, street_nr = tenant.street&.rpartition(' ')
      tenant.update_columns(street:, street_nr:) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def migrate_organisations
    Organisation.find_each do |organisation|
      lines = organisation.account_address.presence&.lines ||
              organisation.creditor_address.presence&.lines ||
              organisation.address&.lines
      next if lines.blank?

      organisation.update!(qr_bill_creditor_address: Address.parse(lines, country_code: 'CH'))
    end
  end

  def migrate_invoice_addresses # rubocop:disable Metrics/CyclomaticComplexity
    Booking.where.not(unstructured_invoice_address: [nil, '']).find_each do |booking|
      lines = booking.unstructured_invoice_address
      invoice_address = Address.parse(lines, country_code: 'CH')
      next if invoice_address.blank?

      invoice_address.assign_attributes(
        recipient: invoice_address.recipient.presence || booking.tenant_organisation.presence || booking.tenant&.name,
        postalcode: invoice_address.postalcode.presence || booking.tenant_address.postalcode,
        city: invoice_address.city.presence || booking.tenant_address&.city
      )
      booking.update_columns(use_invoice_address: true, invoice_address:) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
