class CreateMarkdownTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :markdown_templates do |t|
      t.string :key, index: true #, unique: true
      t.string :interpolatable_type, null: true
      t.string :title
      t.string :locale
      t.text :body

      t.timestamps
    end
  end
end
