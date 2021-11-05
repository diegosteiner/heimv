class CreateOperatorResponsibilities < ActiveRecord::Migration[6.1]
  def change
    add_reference :booking_operators, :home, null: true, foreign_key: true
    add_reference :booking_operators, :organisation, null: false, foreign_key: true
    change_column_null :booking_operators, :booking_id, true
    rename_column :booking_operators, :index, :ordinal
    rename_table :booking_operators, :operator_responsibilities

    reversible do |direction| 
      direction.up do 
        drop_table :home_operators if table_exists?(:home_operators)
      end
    end
  end
end
