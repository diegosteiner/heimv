class AddLimitisToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :homes_limit, :integer, null: true
    add_column :organisations, :users_limit, :integer, null: true
  end
end
