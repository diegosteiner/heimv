class AddCommittedToUsages < ActiveRecord::Migration[7.0]
  def change
    add_column :usages, :committed, :boolean, default: false

    reversible do |direction|
      direction.up do 
        Usage.find_each { |usage| usage.update_columns(committed: usage.booking&.usages_entered) }
      end
    end

    remove_column :bookings, :usages_entered, :boolean, default: false
    remove_column :bookings, :usages_presumed, :boolean, default: false
  end
end
