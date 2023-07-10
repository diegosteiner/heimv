class AddAttributeAndOperatorToBookingConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_conditions, :compare_attribute, :string, null: true
    add_column :booking_conditions, :compare_operator, :string, null: true
    rename_column :booking_conditions, :distinction, :compare_value

    reversible do |direction| 
      direction.up do 
        BookingCondition.where(type: 'BookingConditions::Season').update_all(type: 'BookingConditions::DateSpan')
      end

      direction.down do 
        BookingCondition.where(type: 'BookingConditions::DateSpan').update_all(type: 'BookingConditions::Season')
      end
    end
  end
end
