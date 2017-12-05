class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :street_address
      t.string :zipcode
      t.string :city

      t.timestamps
    end
  end
end
