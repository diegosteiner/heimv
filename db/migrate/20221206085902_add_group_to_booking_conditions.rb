class AddGroupToBookingConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_conditions, :group, :string, null: true

    reversible do |direction|
      direction.up do
        BookingCondition.update_all(group: :selecting)
      end
    end
  end
end
