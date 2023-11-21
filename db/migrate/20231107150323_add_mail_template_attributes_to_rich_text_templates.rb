class AddMailTemplateAttributesToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    Rails.application.eager_load!

    raise StandardError if MailTemplate.definitions.blank?

    add_column :rich_text_templates, :type, :string
    add_index :rich_text_templates, :type
    add_column :rich_text_templates, :attachable_booking_documents, :integer, default: 0

    reversible do |direction|
      direction.up do
        RichTextTemplate.update_all(type: RichTextTemplate.to_s)
        RichTextTemplate.where(key: MailTemplate.definitions.keys).update_all(type: MailTemplate.to_s)
        MailTemplate.find_each(&:reset_attachable_booking_documents!)
      end
    end

    change_column_null :rich_text_templates, :type, true
    rename_column :notifications, :rich_text_template_id, :mail_template_id
  end
end
