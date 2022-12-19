class RemoveMarkdownFromRichTextTemplates < ActiveRecord::Migration[7.0]
  def change
    remove_column :rich_text_templates, :body_i18n_markdown
    remove_reference :agent_bookings, :home
  end
end
