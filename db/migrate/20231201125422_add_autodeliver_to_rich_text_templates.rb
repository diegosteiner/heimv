class AddAutodeliverToRichTextTemplates < ActiveRecord::Migration[7.1]
  def change
    Rails.application.eager_load!

    add_column :rich_text_templates, :autodeliver, :boolean, default: true

    reversible do |direction|
      RichTextTemplate.definitions.each do |key, definition|
        next if definition[:autodeliver].nil? || definition[:autodeliver]

        RichTextTemplate.where(key:).update_all(autodeliver: definition[:autodeliver])
      end
    end
  end
end
