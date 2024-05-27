# frozen_string_literal: true

# == Schema Information
#
# Table name: mail_template_designated_documents
#
#  designated_document_id :bigint
#  mail_template_id       :bigint
#
# Indexes
#
#  idx_on_designated_document_id_590865e4e7                      (designated_document_id)
#  index_mail_template_designated_documents_on_mail_template_id  (mail_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (designated_document_id => designated_documents.id)
#  fk_rails_...  (mail_template_id => rich_text_templates.id)
#
class MailTemplateDesignatedDocument < ApplicationRecord
  belongs_to :mail_template
  belongs_to :designated_document
end
