class AddApiTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :token, :string, null: true, index: true
    add_column :users, :default_calendar_view, :integer, null: true 
  end
end
