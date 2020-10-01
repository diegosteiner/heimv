class MoveAllNotificationMarkdownTemplatesIntoNamespace < ActiveRecord::Migration[6.0]
  def up
    MarkdownTemplate.where(MarkdownTemplate.arel_table[:key].matches('%_message')).find_each do |template|
      template.update(key: template.key.chomp('_message'), namespace: :notification)
    end
  end
end
