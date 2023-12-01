class AddAutodeliverToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :rich_text_templates, :autodeliver, :boolean, default: true
  end
end
