class AllowUserNullOrganisation < ActiveRecord::Migration[6.1]
  def change
    change_column_null :users, :organisation_id, true
  end
end
