# frozen_string_literal: true

class CreateNotificationAttachedDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_attached_designated_documents,
                 primary_key: %i[designated_document_id notification_id] do |t|
      t.belongs_to :designated_document
      t.belongs_to :notification
      t.timestamps
    end
  end
end
