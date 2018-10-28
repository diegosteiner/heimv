class CreateRichTextTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :rich_text_templates do |t|
      t.string :klass
      t.string :variant
      t.string :locale
      t.text :body

      t.timestamps
    end
  end
end
