class AddToAndCcToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :to, :string, array: true, default: []
    add_column :messages, :cc, :string, array: true, default: []
  end
end
