class AddBeginsAtAndEndsAtToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :begins_at, :datetime, null: true
    add_column :bookings, :ends_at, :datetime, null: true
    add_column :bookings, :occupancy_type, :integer, null: false, default: 0
    remove_reference :bookings, :home, index: true, foreign_key: true
    rename_column :bookings, :color, :occupancy_color

    reversible do |direction|
      direction.up do 
        Occupancy.find_each do |occupancy| 
          next unless occupancy.booking.present?

          occupancy.booking.update(begins_at: occupancy.begins_at, ends_at: occupancy.ends_at,
                                    occupancy_type: occupancy.occupancy_type)
        end


      end
    end

    fix_templates
  end

  def fix_templates
    Organisation.find_each do |organisation|
      rtts = RichTextTemplateService.new(organisation)
      rtts.replace_in_template!("booking.occupancy.begins_at", "booking.begins_at")
      rtts.replace_in_template!("booking.occupancy.ends_at", "booking.ends_at")
      rtts.replace_in_template!("booking.occupancy.occupancy_type", "booking.occupancy_type")
      # rtts.replace_in_template!("booking.home_id ==", "booking.home_ids contains")
      # rtts.replace_in_template!("booking.home.", "booking.homes | map: \"\" | join: \", \"")
    end
  end
end
