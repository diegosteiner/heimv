class AddMailTemplateAttributesToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    Rails.application.eager_load!

    raise StandardError if MailTemplate.definitions.blank?

    add_column :rich_text_templates, :type, :string
    add_index :rich_text_templates, :type

    change_column_null :rich_text_templates, :type, true
    rename_column :notifications, :rich_text_template_id, :mail_template_id
    rename_column :notifications, :to, :deliver_to
    add_column :notifications, :to, :string

    reversible do |direction|
      direction.up do
         add_type_to_rich_text_templates
         map_addressed_to_to_to
      end
    end

    remove_column :notifications, :addressed_to, :integer
  end
end

def add_type_to_rich_text_templates
  RichTextTemplate.update_all(type: RichTextTemplate.to_s)
  RichTextTemplate.where(key: MailTemplate.definitions.keys).update_all(type: MailTemplate.to_s)
end

def map_addressed_to_to_to
  mapping = { 0 => :administration, 1 => :tenant, 2=> :booking_agent }

  Notification.find_each do |notification|
    notification.update(to: mapping.fetch(notification[:addressed_to]&.to_i, nil))
  end
end
