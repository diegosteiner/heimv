class AddSettingsToHomes < ActiveRecord::Migration[7.0]
  def change
    add_column :homes, :settings, :jsonb

    reversible do |direction|
      direction.up do
        migrate_organisation_settings 
        migrate_home_settings
      end
    end

    remove_column :homes, :min_occupation, :integer
    remove_column :homes, :booking_margin, :integer
  end

  def migrate_home_settings 
    Home.transaction do
      Home.find_each do |home|
        home.settings ||= HomeSettings.new
        # home.settings.min_occupation = home.min_occupation || 0
        home.settings.booking_margin = home.booking_margin || 0
        home.save!
      end
    end
  end

  def migrate_organisation_settings 
    Organisation.transaction do
      Organisation.find_each do |organisation|
        organisation.settings ||= OrganisationSettings.new
        organisation.save!
      end
    end
  end
end
