class CreateTenants < ActiveRecord::Migration[5.1]
  def change
    create_table :tenants do |t|
      t.string :first_name
      t.string :last_name
      t.string :street_address
      t.string :zipcode
      t.string :city
      t.string :country
      t.boolean :reservations_allowed, null: true
      t.boolean :email_verified, default: false
      t.text :phone, null: true
      t.text :remarks, null: true
      t.string :email, null: false, unique: true, index: true
      t.text   :search_cache, null: false, index: true
      t.date   :birth_date, null: true
      t.jsonb :import_data, null: true

      t.timestamps
    end
  end
end
