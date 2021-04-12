class RenameBookingStrategyToBookingFlow < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :booking_strategy_type, :booking_flow_type 
    add_column :bookings, :booking_flow_type, :string, null: true
    
    reversible do |direction|
      direction.up do 
        Organisation.update_all(booking_flow_type: 'BookingFlows::Default')
      end
      
      direction.down do 
        Organisation.update_all(booking_strategy_type: 'BookingStrategies::Default')
      end
    end
  end
end
