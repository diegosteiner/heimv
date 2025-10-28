# frozen_string_literal: true

class AddStreetNrToTenants < ActiveRecord::Migration[8.0]
  def change
    add_column :tenants, :street_nr, :string
    rename_column :tenants, :street_address, :street
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
      street, _, street_nr = tenant.street&.rpartition(' ')&.[](0..1)
      tenant.update(street:, street_nr:)
    end
  end

  def migrate_organisations
    Organisation.find_each do |organisation|
      lines = organisation.account_address.presence&.lines ||
              organisation.creditor_address.presence&.lines ||
              organisation.address&.lines
      next if lines.blank?

      organisation.update!(qr_bill_creditor_address: Address.parse_lines(lines, country_code: 'CH'))
    end
  end

  def migrate_invoice_addresses
    Booking.where.not(unstructured_invoice_address: [nil, '']).find_each do |booking|
      lines = booking.unstructured_invoice_address
      next if lines.blank?

      booking.update_columns(use_invoice_address: true, # rubocop:disable Rails/SkipsModelValidations
                             invoice_address: Address.parse_lines(lines, country_code: 'CH'))
    end
  end
end
