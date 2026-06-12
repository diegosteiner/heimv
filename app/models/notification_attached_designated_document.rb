# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_attached_designated_documents
#
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  designated_document_id :bigint           not null, primary key
#  notification_id        :bigint           not null, primary key
#
class NotificationAttachedDesignatedDocument < ApplicationRecord
  belongs_to :notification, inverse_of: :notification_attached_designated_documents
  belongs_to :designated_document
end
