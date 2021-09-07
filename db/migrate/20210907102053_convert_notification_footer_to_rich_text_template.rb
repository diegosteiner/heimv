class ConvertNotificationFooterToRichTextTemplate < ActiveRecord::Migration[6.1]
  def up
    Organisation.find_each do |organisation|
      RichTextTemplate.create!(organisation: organisation, key: :notification_footer, 
                                body_de: ::Markdown.new(organisation.notification_footer || '').to_html)
    end

    remove_column :organisations, :notification_footer
  end

  def down
    add_column :organisations, :notification_footer, :text, null: true
  end
end
