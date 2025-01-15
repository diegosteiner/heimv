# frozen_string_literal: true

# == Schema Information
#
# Table name: mail_template_designated_documents
#
#  designated_document_id :bigint
#  mail_template_id       :bigint
#

class MailTemplateDesignatedDocument < ApplicationRecord
  belongs_to :mail_template
  belongs_to :designated_document
end
