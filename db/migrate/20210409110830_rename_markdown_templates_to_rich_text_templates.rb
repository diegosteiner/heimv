class RenameMarkdownTemplatesToRichTextTemplates < ActiveRecord::Migration[6.1]
  def change
    remove_index :markdown_templates, %i[key home_id organisation_id], unique: true
    rename_table :markdown_templates, :rich_text_templates
    rename_column :notifications, :markdown_template_id, :rich_text_template_id
    add_index :rich_text_templates, %i[key home_id organisation_id], unique: true,
                        name: "index_rich_text_templates_on_key_and_home_and_organisation"
  end
end
