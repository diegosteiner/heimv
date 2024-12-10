class AddKeySequenceNumberToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :sequence_number, :integer, null: true
    add_column :tenants, :sequence_number, :integer, null: true
    add_column :bookings, :sequence_number, :integer, null: true
  end

  # protected

  # def backfill_sequence_numbers
  #   Organisation.find_each do |organisation|
  #     organisation.
  #   end
  # end
end
