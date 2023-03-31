class AddSettingsToOccupiables < ActiveRecord::Migration[7.0]
  def change
    add_column :occupiables, :settings, :jsonb
    
    reversible do |direction|
      direction.up do
        Occupiable.find_each do |occupiable|
          begin
            margin = JSON.parse(occupiable.organisation.settings_before_type_cast)&.[]("booking_margin").presence
            occupiable.update(settings: OccupiableSettings.new(booking_margin: margin)) if margin
          rescue StandardError
            
          end
        end
      end
    end
  end
end
