class AddRefTemplateToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :ref_template, :string, default: '%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s'
    remove_column :homes, :ref_template, :string
    remove_index :homes, :ref
    add_index :homes, %i[ref organisation_id], unique: true
  end
end
