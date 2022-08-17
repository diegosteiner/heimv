class AddAcceptConditionsToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :accept_conditions, :boolean, default: false

    # reversible do |direction|
    #   direction.up do 

    #   end
    # end
  end
end
