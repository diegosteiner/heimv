class AddRefTemplateToHomes < ActiveRecord::Migration[6.1]
  def change
    add_column :homes, :ref_template, :string
    remove_column :organisations, :booking_ref_strategy_type, :string
  end
end
