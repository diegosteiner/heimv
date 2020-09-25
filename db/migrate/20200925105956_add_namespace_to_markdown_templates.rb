class AddNamespaceToMarkdownTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :markdown_templates, :namespace, :string
    add_index :markdown_templates, :namespace
    add_reference :markdown_templates, :home, null: true, foreign_key: true
    remove_index :markdown_templates, column: %i[key locale organisation_id], unique: true
    add_index :markdown_templates, %i[key locale organisation_id home_id namespace], 
                                   unique: true, 
                                   name: 'index_markdown_templates_on_key_composition'
  end
end
