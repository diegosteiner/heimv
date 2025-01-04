class AddKeySequenceNumbers < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :sequence_number, :integer, null: true
    add_column :invoices, :sequence_year, :integer, null: true
    add_column :bookings, :sequence_number, :integer, null: true
    add_column :bookings, :sequence_year, :integer, null: true
    add_column :tenants, :sequence_number, :integer, null: true
  end
end
