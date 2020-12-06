class RenameLabel2ToBreakdown < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoice_parts, :label_2, :breakdown
  end
end
