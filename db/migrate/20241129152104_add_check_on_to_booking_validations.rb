class AddCheckOnToBookingValidations < ActiveRecord::Migration[8.0]
  def change
    add_column :booking_validations, :check_on, :integer, default: 0, null: false
  end
end
