# frozen_string_literal: true

# == Schema Information
#
# Table name: mail_template_designated_documents
#
#  mail_template_id       :integer
#  designated_document_id :integer
#
# Indexes
#
#  idx_on_designated_document_id_590865e4e7                      (designated_document_id)
#  index_mail_template_designated_documents_on_mail_template_id  (mail_template_id)
#

class MailTemplateDesignatedDocument < ApplicationRecord
  belongs_to :mail_template
  belongs_to :designated_document
end
