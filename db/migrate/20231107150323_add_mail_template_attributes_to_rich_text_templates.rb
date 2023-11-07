class AddMailTemplateAttributesToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :rich_text_templates, :type, :string
    add_index :rich_text_templates, :type

    reversible do |direction|
      direction.up do
        RichTextTemplate.update_all(type: RichTextTemplate.to_s)
        RichTextTemplate.where(key: MailTemplate.definitions.keys).update_all(type: MailTemplate.to_s)
      end
    end

    change_column_null :rich_text_templates, :type, true
  end
end
