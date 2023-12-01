class AddAutodeliverToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :rich_text_templates, :autodeliver, :boolean, default: true

    reversible do |direction|
      RichTextTemplate.definitions.each do |key, definition|
        next if definition[:autodeliver].nil? || definition[:autodeliver]

        Notification.where(key:).update_all(autodeliver: definition[:autodeliver])
      end
    end
  end
end
