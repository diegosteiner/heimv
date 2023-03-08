class AddHomeIdToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :occupancies, :linked, :boolean, default: true
    add_column :bookings, :home_id, :integer, null: true, index: true, foreign_key: { to_table: :occupiables }

    reversible do |direction|
      direction.up do 
        Booking.find_each do |booking| 
          booking.instance_exec do 
            self.approximate_headcount = 0 if approximate_headcount&.negative?
            self.tenant_organisation = tenant_organisation[0..149] if tenant_organisation&.length&.>(149)
            update!(home_id: occupiable_ids.first) 
          end
        rescue ActiveRecord::RecordInvalid
          puts "#{booking.id} #{booking.booking_state}! #{booking.errors.details}"
          
          return booking.destroy if booking.errors.include?('occupancies.begins_at') || 
                                    booking.errors.include?('occupancies.ends_at')

          booking.update(booking.organisation.homes.first) if booking.errors.include?(:home) &&
                                                              booking.organisation.homes.count == 1 

        end
      end
    end

    change_column_null :bookings, :home_id, false
  end
end
