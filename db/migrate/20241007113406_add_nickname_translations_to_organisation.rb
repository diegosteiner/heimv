class AddNicknameTranslationsToOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :organisations, :nickname_label_i18n, :jsonb, default: {}
  end
end
