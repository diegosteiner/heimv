class RemoveActiveFromOccupiables < ActiveRecord::Migration[7.1]
  def change
    add_column :occupiables, :discarded_at, :datetime
    add_index :occupiables, :discarded_at

    reversible do |direction|
      Occupiable.where(active: false).update_all(discarded_at: Time.zone.now)
    end

    remove_column :occupiables, :active, :boolean, default: true
  end
end
