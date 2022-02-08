class RenameManageUpcomingSoonNotification < ActiveRecord::Migration[7.0]
  def up
    RichTextTemplate.where(key: :manage_upcoming_soon_notification)
      .update_all(key: :operator_upcoming_soon_notification)
  end

  def down
    RichTextTemplate.where(key: :operator_upcoming_soon_notification)
      .update_all(key: :manage_upcoming_soon_notification)
  end
end
