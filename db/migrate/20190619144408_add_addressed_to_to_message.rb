class AddAddressedToToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :addressed_to, :integer, null: false, default: 0
  end
end
