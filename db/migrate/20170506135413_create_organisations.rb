class CreateOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations do |t|
      t.string :name
      t.text :address
      t.string :booking_strategy_type
      t.string :invoice_ref_strategy_type
      t.text :payment_information
      t.string :account_nr
      t.text :message_footer

      t.timestamps
    end
  end
end
