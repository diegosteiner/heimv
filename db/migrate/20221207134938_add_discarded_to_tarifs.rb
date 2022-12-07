class AddDiscardedToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :tarifs, :discarded_at, :datetime
    add_index :tarifs, :discarded_at
    add_index :booking_conditions, [:qualifiable_id, :qualifiable_type, :group], 
              name: 'index_booking_conditions_on_qualifiable'
  end
end
