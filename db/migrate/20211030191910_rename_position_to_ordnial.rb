class RenamePositionToOrdnial < ActiveRecord::Migration[6.1]
  def change
    rename_column :booking_purposes, :position, :ordinal
    rename_column :invoice_parts, :position, :ordinal
    rename_column :tarifs, :position, :ordinal
  end
end
