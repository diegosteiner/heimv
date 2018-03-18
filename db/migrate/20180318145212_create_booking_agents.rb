class CreateBookingAgents < ActiveRecord::Migration[5.2]
  def change
    create_table :booking_agents do |t|
      t.string :name
      t.string :code, index: true, unique: true
      t.string :email

      t.timestamps
    end
  end
end
