class AddTypeToRichTextTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :rich_text_templates, :enabled, :boolean, default: true 
  end
end
