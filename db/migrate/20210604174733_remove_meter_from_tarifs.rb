class RemoveMeterFromTarifs < ActiveRecord::Migration[6.1]
  def change
    remove_column :tarifs, :meter, :string
  end
end
