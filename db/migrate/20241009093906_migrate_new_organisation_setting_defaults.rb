class MigrateNewOrganisationSettingDefaults < ActiveRecord::Migration[7.2]
  def up
    Organisation.find_each do |organisation|
      organisation.settings.predefined_salutation_form = :informal_neutral # mimic previous behaviour
      organisation.nickname_label_i18n = {
        de: 'Pfadiname',
        fr: 'Totem',
        it: 'Totem scout',
        en: 'Scoutname'
      }
      organisation.save
    end
  end
end
