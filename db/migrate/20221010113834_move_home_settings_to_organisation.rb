class MoveHomeSettingsToOrganisation < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        Home.find_each do |home|
          organisation = home.organisation
          organisation.update(settings: organisation.settings.to_h.merge(home.settings.to_h))
        end
      end
    end

    remove_column :homes, :settings, :jsonb
  end
end
