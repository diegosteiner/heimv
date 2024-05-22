class CreateMailTemplateDesignatedDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_template_designated_documents, id: false do |t|
      t.belongs_to :mail_template, foreign_key: { to_table: :rich_text_templates }
      t.belongs_to :designated_document, foreign_key: true
    end

    reversible do |direction|
      direction.up do
        DesignatedDocument.find_each do |designated_document|
          link_mail_templates(designated_document)
        end
      end
    end
  end

  def link_mail_templates(document)
    templates = MailTemplate.where(organisation: document.organisation)

    document.mail_templates << templates.by_key(:awaiting_contract_notification) if document.send_with_contract
    document.mail_templates << templates.by_key(:provisional_request_notification) if document.send_with_accepted
    document.mail_templates << templates.by_key(:definitive_request_notification) if document.send_with_accepted
    document.mail_templates << templates.by_key(:upcoming_soon_notification) if document.send_with_last_infos

    document.save
  end
end
